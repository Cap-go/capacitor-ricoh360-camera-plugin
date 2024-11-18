export interface Ricoh360CameraPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
