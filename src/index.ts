import { registerPlugin } from '@capacitor/core';

import type { Ricoh360CameraPlugin } from './definitions';

const Ricoh360Camera = registerPlugin<Ricoh360CameraPlugin>('Ricoh360Camera', {
  web: () => import('./web').then((m) => new m.Ricoh360CameraWeb()),
});

export * from './definitions';
export { Ricoh360Camera };
