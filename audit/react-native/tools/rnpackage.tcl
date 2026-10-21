# rnpackage.tcl -- a prototype of the React Native plugin's generator
# (REACT-NATIVE-TARGET-CENSUS.md, "Package-generation model"): an
# installable React Native library around a Botlish C ABI library, a Pure
# C++ TurboModule with no Java, Kotlin or Swift.
#
#   tclsh9.0 audit/react-native/tools/rnpackage.tcl -o DIR \
#       -exports P_botlish.exports -header P_botlish.h -name NPM-NAME \
#       ?-version V? ?-module NAME? ?-java-package P? ?-react-native V? \
#       ?-android-lib ABI LIB.a ...? ?-ios-lib LIB.a? ?-codegen-project DIR?
#
# Everything it reads is the library mode's output (libmode.tcl): the export
# manifest (NAME C-SYMBOL {PARAM TYPE ...} RESULT {ERRORS} per line) and the
# C header. It never reads Botlish source or HIR: the C ABI is the boundary.
#
# What it writes, all of it React Native's own conventions (the
# create-react-native-library 0.63.1 `turbo-module`/`cpp` template, and the
# React Native 0.88 sources the census cites):
#
#   package.json            codegenConfig (type modules, ios.modulesProvider)
#   react-native.config.js  Android: a pure C++ dependency (cxxModule*)
#   src/NativeMODULE.ts     the Codegen spec (TypeScript)
#   src/index.ts            the typed JS entry point
#   cpp/MODULEModule.{h,cpp}  the adapter: NativeMODULECxxSpec<T> over the C ABI
#   botlish/P_botlish.h     the C ABI
#   android/CMakeLists.txt  the adapter and the imported Botlish library
#   android/libs/ABI/libP_botlish.a
#   ios/MODULEModuleProvider.mm   RCTModuleProvider
#   ios/lib/libP_botlish.a
#   MODULE.podspec
#   android/generated, ios/generated   Codegen's output, when -codegen-project
#                           names a React Native project to run it from
#                           (includesGeneratedCode); otherwise the app runs
#                           Codegen.
#
# Output is deterministic: no time, host path or directory order.

proc usage {} {
    puts stderr "usage: tclsh9.0 rnpackage.tcl -o DIR -exports FILE -header FILE -name NPM-NAME ?options?"
    exit 2
}

set opts [dict create -version 0.1.0 -module "" -java-package "" -react-native 0.88.0 \
    -android-lib {} -ios-lib "" -codegen-project ""]
while {[llength $argv]} {
    set argv [lassign $argv option]
    switch -- $option {
        -android-lib {
            set argv [lassign $argv abi lib]
            dict lappend opts -android-lib $abi [file normalize $lib]
        }
        -o - -exports - -header - -name - -version - -module - -java-package - -react-native - -ios-lib - -codegen-project {
            set argv [lassign $argv value]
            dict set opts $option $value
        }
        default { usage }
    }
}
foreach required {-o -exports -header -name} {
    if {![dict exists $opts $required]} { usage }
}
set out [file normalize [dict get $opts -o]]
set npm [dict get $opts -name]
if {![regexp {^(@[a-z0-9][a-z0-9._-]*/)?[a-z0-9][a-z0-9._-]*$} $npm]} {
    error "not an npm package name: $npm"
}

# ---------------------------------------------------------------------------
# Names. Every name an app shares with other packages is derived from the
# npm name (unique in the app's node_modules) unless given: the JS module
# name, which Codegen's iOS step refuses to see twice; the C++ class (one
# namespace, facebook::react, for every C++ TurboModule); the Objective-C
# provider class (one runtime namespace); the pod; the CMake target.

proc pascal {text} {
    set out ""
    foreach part [regexp -all -inline {[A-Za-z0-9]+} $text] {
        append out [string toupper [string index $part 0]][string range $part 1 end]
    }
    return $out
}

proc camel {text} {
    set p [pascal $text]
    return [string tolower [string index $p 0]][string range $p 1 end]
}

set bare [regsub {^@[^/]+/} $npm ""]
set module [dict get $opts -module]
if {$module eq ""} {
    set module [pascal [regsub {^react-native-} $bare ""]]
}
if {![regexp {^[A-Z][A-Za-z0-9]*$} $module]} {
    error "not a module name: $module"
}
set class ${module}Module
set provider ${module}ModuleProvider
set spec ${module}Spec
set target $bare
set javaPackage [dict get $opts -java-package]
if {$javaPackage eq ""} {
    set javaPackage com.[string tolower [regsub -all {[^A-Za-z0-9]} $module ""]]
}

# ---------------------------------------------------------------------------
# The exports.

set f [open [dict get $opts -exports]]
set exports {}
foreach line [split [read $f] \n] {
    if {[string trim $line] ne ""} {
        lappend exports $line
    }
}
close $f
set headerName [file tail [dict get $opts -header]]
set prefix [regsub {_botlish\.h$} $headerName ""]

set jsNames {}
foreach export $exports {
    lassign $export name symbol params result errors
    set js [camel $name]
    # A TurboModule's methods share one object with getConstants and the
    # JS object protocol.
    if {$js in {getConstants constructor toString valueOf hasOwnProperty}} {
        error "$name: its JS name $js is reserved"
    }
    if {[dict exists $jsNames $js]} {
        error "$name and [dict get $jsNames $js] have the same JS name $js"
    }
    dict set jsNames $js $name
}

proc tsType {t} {
    return [dict get {int number str string bool boolean unit void} $t]
}

proc cxxType {t} {
    return [dict get {int double str std::string bool bool unit void} $t]
}

# ---------------------------------------------------------------------------
# A JSON writer for the one JSON file written here: values are tagged
# {obj {KEY VALUE ...}} {arr {VALUE ...}} {str TEXT} {lit TEXT}.

proc jsonString {text} {
    set map [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t]
    return "\"[string map $map $text]\""
}

proc json {value {indent ""}} {
    lassign $value tag body
    set inner "$indent  "
    switch -- $tag {
        str { return [jsonString $body] }
        lit { return $body }
        arr {
            if {![llength $body]} { return {[]} }
            set items [lmap v $body { string cat $inner [json $v $inner] }]
            return "\[\n[join $items ",\n"]\n$indent\]"
        }
        obj {
            if {![llength $body]} { return "{}" }
            set items {}
            foreach {k v} $body {
                lappend items "$inner[jsonString $k]: [json $v $inner]"
            }
            return "\{\n[join $items ",\n"]\n$indent\}"
        }
    }
    error "bad JSON value $value"
}

proc write {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -translation lf -encoding utf-8
    puts -nonewline $f $text
    close $f
}

set codegen [expr {[dict get $opts -codegen-project] ne ""}]
set rnMajor [join [lrange [split [dict get $opts -react-native] .] 0 1] .]

set codegenConfig [list name [list str $spec] type {str modules} jsSrcsDir {str src}]
if {$codegen} {
    lappend codegenConfig outputDir {obj {ios {str ios/generated} android {str android/generated}}}
}
lappend codegenConfig android [list obj [list javaPackageName [list str $javaPackage]]]
lappend codegenConfig ios [list obj [list modulesProvider [list obj [list $module [list str $provider]]]]]
lappend codegenConfig includesGeneratedCode [list lit [expr {$codegen ? "true" : "false"}]]

set files {src cpp botlish android ios *.podspec react-native.config.js !android/build !ios/build}
set package [list obj [list \
    name [list str $npm] \
    version [list str [dict get $opts -version]] \
    description [list str "Botlish functions as a React Native Pure C++ TurboModule ($module)"] \
    main {str src/index.ts} \
    types {str src/index.ts} \
    react-native {str src/index.ts} \
    files [list arr [lmap p $files { list str $p }]] \
    license {str MIT} \
    peerDependencies [list obj [list react-native [list str ">=$rnMajor.0"]]] \
    codegenConfig [list obj $codegenConfig]]]
write [file join $out package.json] "[json $package]\n"

write [file join $out react-native.config.js] [string map [list @TARGET@ $target @CLASS@ $class @CMAKELISTS@ \
        [expr {$codegen ? "\n        cmakeListsPath: 'generated/jni/CMakeLists.txt'," : ""}]] {// Generated by audit/react-native/tools/rnpackage.tcl (REACT-NATIVE-TARGET-CENSUS.md).
// Android autolinking treats a package with these three keys and no
// build.gradle as a pure C++ dependency: it adds android/CMakeLists.txt to
// the app's native build and constructs @CLASS@ in its C++ module provider.
module.exports = {
  dependency: {
    platforms: {
      android: {@CMAKELISTS@
        cxxModuleCMakeListsModuleName: '@TARGET@',
        cxxModuleCMakeListsPath: 'CMakeLists.txt',
        cxxModuleHeaderName: '@CLASS@',
      },
    },
  },
};
}]

# ---------------------------------------------------------------------------
# JS: the Codegen spec and the entry point.

set methods {}
set wrappers {}
foreach export $exports {
    lassign $export name symbol params result errors
    set js [camel $name]
    set args [lmap {p t} $params { string cat [camel $p] ": " [tsType $t] }]
    lappend methods "  $js\([join $args {, }]\): [tsType $result];"
    set doc "/** Botlish `$name\([join [lmap {p t} $params { string cat $p ": " $t }] {, }]\) -> $result`"
    if {[llength $errors]} {
        append doc "; throws an Error whose code is one of [join $errors {, }]"
    }
    append doc ". */"
    lappend wrappers "$doc\nexport function $js\([join $args {, }]\): [tsType $result] \{\n  return Native$module.$js\([join [lmap {p t} $params { camel $p }] {, }]\);\n\}"
}
write [file join $out src Native$module.ts] "// Generated by audit/react-native/tools/rnpackage.tcl: the Codegen spec of\n// the Botlish exports (REACT-NATIVE-TARGET-CENSUS.md).\nimport \{ TurboModuleRegistry, type TurboModule \} from 'react-native';\n\nexport interface Spec extends TurboModule \{\n[join $methods \n]\n\}\n\nexport default TurboModuleRegistry.getEnforcing<Spec>('$module');\n"
write [file join $out src index.ts] "// Generated by audit/react-native/tools/rnpackage.tcl.\nimport Native$module from './Native$module';\n\n[join $wrappers \n\n]\n"

# ---------------------------------------------------------------------------
# C++: the adapter.

set decls {}
set defs {}
foreach export $exports {
    lassign $export name symbol params result errors
    set js [camel $name]
    set cxxParams [list "jsi::Runtime &rt"]
    set call {}
    set position 0
    foreach {p t} $params {
        set v [camel $p]
        lappend cxxParams "[cxxType $t] $v"
        switch -- $t {
            int { lappend call "intArgument(rt, \"$js\", $position, $v)" }
            bool { lappend call $v }
            str { lappend call "reinterpret_cast<const uint8_t *>($v.data())" "$v.size()" }
        }
        incr position
    }
    lappend decls "  [cxxType $result] $js\([join $cxxParams {, }]\);"
    set body ""
    switch -- $result {
        int { append body "  int64_t out = 0;\n"; lappend call "&out" }
        bool { append body "  bool out = false;\n"; lappend call "&out" }
        str { append body "  BotlishStr out;\n"; lappend call "&out" }
    }
    append body "  check(rt, \"$js\", $symbol\([join $call {, }]\));\n"
    switch -- $result {
        int { append body "  return intResult(rt, \"$js\", out);\n" }
        bool { append body "  return out;\n" }
        str { append body "  return std::string(reinterpret_cast<const char *>(out.ptr), out.len);\n" }
    }
    lappend defs "[cxxType $result] ${class}::${js}\([join $cxxParams {, }]\) \{\n$body\}"
}

write [file join $out cpp $class.h] [string map [list @CLASS@ $class @SPEC@ $spec @MODULE@ $module @DECLS@ [join $decls \n]] {// Generated by audit/react-native/tools/rnpackage.tcl (REACT-NATIVE-TARGET-CENSUS.md):
// the Pure C++ TurboModule @MODULE@, Codegen's NativeModuleCxxSpec over the
// Botlish C ABI. The class name is also this header's name, which Android
// autolinking includes and constructs (cxxModuleHeaderName).
#pragma once

#include <@SPEC@JSI.h>

#include <memory>
#include <string>

namespace facebook::react {

class @CLASS@ : public Native@MODULE@CxxSpec<@CLASS@> {
 public:
  explicit @CLASS@(std::shared_ptr<CallInvoker> jsInvoker);

@DECLS@
};

} // namespace facebook::react
}]

write [file join $out cpp $class.cpp] [string map [list @CLASS@ $class @MODULE@ $module @HEADER@ $headerName @PREFIX@ $prefix @DEFS@ [join $defs \n\n]] {// Generated by audit/react-native/tools/rnpackage.tcl (REACT-NATIVE-TARGET-CENSUS.md).
// Every conversion is checked: a JS number reaches a Botlish Int only if it
// is an integer of at most Number.MAX_SAFE_INTEGER in magnitude, and an Int
// result returns only if JS holds it exactly. A Botlish error becomes a JS
// Error whose `code` is its identity (a declared error's canonical name, or
// the runtime error's code).
#include "@CLASS@.h"

#include "@HEADER@"

#include <cmath>

namespace facebook::react {

namespace {

constexpr double kMaxSafe = 9007199254740991.0;

[[noreturn]] void throwError(jsi::Runtime &rt, const char *ctor, const std::string &code, const std::string &message) {
  auto error = rt.global().getPropertyAsFunction(rt, ctor).callAsConstructor(rt, message).asObject(rt);
  error.setProperty(rt, "code", jsi::String::createFromUtf8(rt, code));
  throw jsi::JSError(rt, jsi::Value(rt, error));
}

int64_t intArgument(jsi::Runtime &rt, const char *method, int position, double x) {
  if (!std::isfinite(x) || std::trunc(x) != x || std::fabs(x) > kMaxSafe) {
    throwError(rt, "TypeError", "BOTLISH_ARGUMENT",
        std::string(method) + ": argument " + std::to_string(position) + " must be a safe integer");
  }
  return static_cast<int64_t>(x);
}

double intResult(jsi::Runtime &rt, const char *method, int64_t n) {
  if (n > 9007199254740991LL || n < -9007199254740991LL) {
    throwError(rt, "RangeError", "BOTLISH_INT_RANGE", std::string(method) + ": the result is not a safe integer");
  }
  return static_cast<double>(n);
}

void check(jsi::Runtime &rt, const char *method, int32_t status) {
  switch (status) {
    case @PREFIX@_OK:
      return;
    case @PREFIX@_INT_RANGE:
      throwError(rt, "RangeError", "BOTLISH_INT_RANGE", std::string(method) + ": the result does not fit in 64 bits");
    case @PREFIX@_BAD_UTF8:
      throwError(rt, "TypeError", "BOTLISH_ARGUMENT", std::string(method) + ": a String argument is not valid UTF-8");
    default: {
      BotlishStr identity, message;
      @PREFIX@_last_error(&identity, &message);
      throwError(rt, "Error", std::string(reinterpret_cast<const char *>(identity.ptr), identity.len),
          std::string(method) + ": " + std::string(reinterpret_cast<const char *>(message.ptr), message.len));
    }
  }
}

} // namespace

@CLASS@::@CLASS@(std::shared_ptr<CallInvoker> jsInvoker)
    : Native@MODULE@CxxSpec(std::move(jsInvoker)) {}

@DEFS@

} // namespace facebook::react
}]

file mkdir [file join $out botlish]
file copy -force [dict get $opts -header] [file join $out botlish $headerName]

# The C ABI on a CPU the Botlish library was not built for (Cranelift has no
# 32-bit ARM or x86 backend, and React Native's app template builds both):
# every call fails with BOTLISH_UNAVAILABLE, so the app still builds for
# every ABI it targets, unmodified.
set stubs {}
foreach export $exports {
    lassign $export name symbol params result errors
    set cparams {}
    foreach {p t} $params {
        switch -- $t {
            int { lappend cparams "int64_t $p" }
            bool { lappend cparams "bool $p" }
            str { lappend cparams "const uint8_t *${p}_ptr" "size_t ${p}_len" }
        }
    }
    switch -- $result {
        int { lappend cparams "int64_t *out" }
        bool { lappend cparams "bool *out" }
        str { lappend cparams "BotlishStr *out" }
    }
    set unused [lmap c $cparams { string cat "(void)" [lindex [regexp -inline {\w+$} $c] 0] ";" }]
    lappend stubs "int32_t $symbol\([join $cparams {, }]\) \{\n  [join $unused { }]\n  return ${prefix}_ERROR;\n\}"
}
write [file join $out botlish ${prefix}_unavailable.c] [string map [list @HEADER@ $headerName @PREFIX@ $prefix @STUBS@ [join $stubs \n\n]] {/* Generated by audit/react-native/tools/rnpackage.tcl (REACT-NATIVE-TARGET-CENSUS.md):
   the C ABI where no Botlish library exists for the CPU being built. */
#include "@HEADER@"

static const char identity[] = "BOTLISH_UNAVAILABLE";
static const char message[] = "this Botlish library was not built for this CPU architecture";

void @PREFIX@_last_error(BotlishStr *i, BotlishStr *m) {
  i->ptr = (const uint8_t *)identity;
  i->len = sizeof identity - 1;
  m->ptr = (const uint8_t *)message;
  m->len = sizeof message - 1;
}

@STUBS@
}]

# ---------------------------------------------------------------------------
# Android: the adapter's CMake target, linked into the app's libappmodules.so
# with the Botlish library of the ABI being built.

write [file join $out android CMakeLists.txt] [string map [list @TARGET@ $target @CLASS@ $class @SPEC@ $spec @PREFIX@ $prefix] {# Generated by audit/react-native/tools/rnpackage.tcl (REACT-NATIVE-TARGET-CENSUS.md).
cmake_minimum_required(VERSION 3.13)
project(@TARGET@)

set(BOTLISH_LIBRARY "${CMAKE_CURRENT_SOURCE_DIR}/libs/${ANDROID_ABI}/lib@PREFIX@_botlish.a")
if(EXISTS "${BOTLISH_LIBRARY}")
  add_library(botlish_@PREFIX@ STATIC IMPORTED)
  set_target_properties(botlish_@PREFIX@ PROPERTIES IMPORTED_LOCATION "${BOTLISH_LIBRARY}")
else()
  message(STATUS "@TARGET@: no Botlish library for ${ANDROID_ABI}; its calls fail with BOTLISH_UNAVAILABLE")
  add_library(botlish_@PREFIX@ STATIC ../botlish/@PREFIX@_unavailable.c)
  target_include_directories(botlish_@PREFIX@ PRIVATE ../botlish)
endif()

add_library(@TARGET@ STATIC ../cpp/@CLASS@.cpp)
set_target_properties(@TARGET@ PROPERTIES
    CXX_STANDARD 20
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF)
target_include_directories(@TARGET@ PUBLIC ../cpp ../botlish)
# The Botlish library is a Rust static library: its runtime's and std's
# symbols stay inside libappmodules.so, and std needs these system libraries.
target_link_options(@TARGET@ INTERFACE "-Wl,--exclude-libs,lib@PREFIX@_botlish.a")
target_link_libraries(@TARGET@ jsi reactnative react_codegen_@SPEC@ botlish_@PREFIX@ log dl m)
}]
foreach {abi lib} [dict get $opts -android-lib] {
    file mkdir [file join $out android libs $abi]
    file copy -force $lib [file join $out android libs $abi lib${prefix}_botlish.a]
}

# ---------------------------------------------------------------------------
# iOS: the module provider the app's Codegen lists in RCTModuleProviders,
# and the pod.

write [file join $out ios $provider.mm] [string map [list @PROVIDER@ $provider @CLASS@ $class] {// Generated by audit/react-native/tools/rnpackage.tcl (REACT-NATIVE-TARGET-CENSUS.md):
// the RCTModuleProvider that codegenConfig.ios.modulesProvider names.
#import <Foundation/Foundation.h>
#import <ReactCommon/RCTTurboModule.h>

#import "@CLASS@.h"

@interface @PROVIDER@ : NSObject <RCTModuleProvider>
@end

@implementation @PROVIDER@

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::@CLASS@>(params.jsInvoker);
}

@end
}]
set vendored ""
if {[dict get $opts -ios-lib] ne ""} {
    file mkdir [file join $out ios lib]
    file copy -force [dict get $opts -ios-lib] [file join $out ios lib lib${prefix}_botlish.a]
    set vendored "\n  s.vendored_libraries = \"ios/lib/lib${prefix}_botlish.a\""
}
set sources {"ios/**/*.{h,mm}", "cpp/**/*.{h,cpp}", "botlish/*.h"}
if {$vendored eq ""} {
    append sources ", \"botlish/${prefix}_unavailable.c\""
}
if {$codegen} {
    append sources {, "ios/generated/**/*.{h,cpp,mm}"}
}
write [file join $out $module.podspec] [string map [list @MODULE@ $module @SOURCES@ $sources @VENDORED@ $vendored] {# Generated by audit/react-native/tools/rnpackage.tcl (REACT-NATIVE-TARGET-CENSUS.md).
require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "@MODULE@"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = "https://example.invalid/botlish"
  s.license      = package["license"]
  s.authors      = "Botlish"
  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://example.invalid/botlish.git", :tag => s.version.to_s }

  s.source_files = @SOURCES@
  s.private_header_files = "ios/**/*.h", "botlish/*.h"@VENDORED@

  install_modules_dependencies(s)
end
}]

# ---------------------------------------------------------------------------
# Codegen, run from a React Native project's own installation (its
# node_modules has react-native and @react-native-community/cli).

if {$codegen} {
    set project [file normalize [dict get $opts -codegen-project]]
    foreach {platform dir} {android android/generated ios ios/generated} {
        file delete -force [file join $out $dir]
        set command [list npx --no-install @react-native-community/cli codegen --source library \
            --path $out --platform $platform --outputPath [file join $out $dir]]
        set here [pwd]
        cd $project
        try {
            exec {*}$command >@stdout 2>@stderr
        } finally {
            cd $here
        }
    }
}
puts "package: $out ($npm, module $module, [llength $exports] methods)"
