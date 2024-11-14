export interface Ricoh360CameraPluginPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
