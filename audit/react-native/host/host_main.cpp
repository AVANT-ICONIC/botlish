// host_main.cpp -- a host-side stand-in for a React Native app's JS runtime
// (REACT-NATIVE-TARGET-CENSUS.md): Hermes (the tag React Native 0.88 pins),
// React Native's own TurboModuleBinding installing global.__turboModuleProxy,
// the Codegen spec and the generated adapter (MODULE_CLASS, MODULE_HEADER:
// -D on the command line) over the Botlish C ABI. It
// runs the JS file given as argv[1].
#include MODULE_HEADER

#include <ReactCommon/CallInvoker.h>
#include <ReactCommon/TurboModuleBinding.h>
#include <hermes/hermes.h>

#include <deque>
#include <fstream>
#include <iostream>
#include <sstream>

using namespace facebook;
using namespace facebook::react;

namespace {

// The JS thread's task queue: invokeAsync work runs after the script, on the
// same thread, as React Native's JS message queue would run it.
class QueueInvoker : public CallInvoker {
 public:
  std::deque<CallFunc> tasks;
  jsi::Runtime *runtime = nullptr;
  void invokeAsync(CallFunc &&func) noexcept override { tasks.push_back(std::move(func)); }
  void invokeSync(CallFunc &&func) override { func(*runtime); }
};

} // namespace

int main(int argc, char **argv) {
  if (argc != 2) {
    std::cerr << "usage: host_main SCRIPT.js\n";
    return 2;
  }
  std::ifstream file(argv[1]);
  std::stringstream source;
  source << file.rdbuf();

  auto runtime = facebook::hermes::makeHermesRuntime();
  jsi::Runtime &rt = *runtime;
  auto invoker = std::make_shared<QueueInvoker>();
  invoker->runtime = &rt;

  rt.global().setProperty(rt, "print", jsi::Function::createFromHostFunction(rt, jsi::PropNameID::forAscii(rt, "print"), 1,
      [](jsi::Runtime &rt, const jsi::Value &, const jsi::Value *args, size_t count) {
        for (size_t i = 0; i < count; i++) {
          std::cout << (i ? " " : "") << args[i].toString(rt).utf8(rt);
        }
        std::cout << std::endl;
        return jsi::Value::undefined();
      }));

  TurboModuleBinding::install(rt, [invoker](jsi::Runtime &, const std::string &name) -> std::shared_ptr<TurboModule> {
    if (name == MODULE_CLASS::kModuleName) {
      return std::make_shared<MODULE_CLASS>(invoker);
    }
    return nullptr;
  });

  try {
    rt.evaluateJavaScript(std::make_shared<jsi::StringBuffer>(source.str()), argv[1]);
    while (!invoker->tasks.empty()) {
      auto task = std::move(invoker->tasks.front());
      invoker->tasks.pop_front();
      task(rt);
    }
  } catch (const jsi::JSError &error) {
    std::cerr << "uncaught JS error: " << error.getMessage() << "\n" << error.getStack() << std::endl;
    return 1;
  }
  return 0;
}
