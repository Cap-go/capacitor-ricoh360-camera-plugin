import { WebPlugin } from '@capacitor/core';

import type { Ricoh360CameraPlugin } from './definitions';

export class Ricoh360CameraWeb extends WebPlugin implements Ricoh360CameraPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
