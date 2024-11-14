import { registerPlugin } from '@capacitor/core';

import type { Ricoh360CameraPluginPlugin } from './definitions';

const Ricoh360CameraPlugin = registerPlugin<Ricoh360CameraPluginPlugin>('Ricoh360CameraPlugin', {
  web: () => import('./web').then((m) => new m.Ricoh360CameraPluginWeb()),
});

export * from './definitions';
export { Ricoh360CameraPlugin };
