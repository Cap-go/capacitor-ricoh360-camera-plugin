import type { CapacitorConfig } from '@capacitor/cli';

import pkg from './package.json';

const config: CapacitorConfig = {
  appId: 'app.capgo.ricoh360.camera.plugin',
  appName: '@capgo/capacitor-ricoh360',
  webDir: 'dist',
  plugins: {
    SplashScreen: {
      launchAutoHide: false,
      launchShowDuration: 0,
    },
    CapacitorUpdater: {
      appId: 'app.capgo.ricoh360.camera.plugin',
      autoUpdate: true,
      autoSplashscreen: true,
      directUpdate: 'always',
      version: pkg.version,
    },
  },
};

export default config;
