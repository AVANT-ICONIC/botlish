// NativeBotlishAsync.ts -- the Codegen spec of host_async.cpp's hand-written
// Promise-returning module (REACT-NATIVE-TARGET-CENSUS.md). host-spike.tcl
// adds it to the generated package before running Codegen again.
import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  depth(n: number): Promise<number>;
  reverse(s: string): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('BotlishAsync');
