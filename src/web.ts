import { WebPlugin } from '@capacitor/core';

import type { Ricoh360CameraPluginPlugin } from './definitions';

export class Ricoh360CameraPluginWeb extends WebPlugin implements Ricoh360CameraPluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
