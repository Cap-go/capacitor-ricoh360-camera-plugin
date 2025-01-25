# ricoh360-camera

Provides an SDK for the Ricoh360 cameras for Capacitor

## Install

```bash
npm install ricoh360-camera
npx cap sync
```

## API

<docgen-index>

* [`initialize(...)`](#initialize)
* [`capturePicture(...)`](#capturepicture)
* [`captureVideo(...)`](#capturevideo)
* [`livePreview(...)`](#livepreview)
* [`stopLivePreview()`](#stoplivepreview)
* [`readSettings()`](#readsettings)
* [`setSettings(...)`](#setsettings)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initialize(...)

```typescript
initialize(options: InitializeOptions) => Promise<CameraInfo>
```

Initializes the SDK

| Param         | Type                                                            |
| ------------- | --------------------------------------------------------------- |
| **`options`** | <code><a href="#initializeoptions">InitializeOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#camerainfo">CameraInfo</a>&gt;</code>

--------------------


### capturePicture(...)

```typescript
capturePicture(options: PictureCaptureOptions) => Promise<CommandResponse>
```

Captures a picture

| Param         | Type                                                                    |
| ------------- | ----------------------------------------------------------------------- |
| **`options`** | <code><a href="#picturecaptureoptions">PictureCaptureOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### captureVideo(...)

```typescript
captureVideo(options: VideoCaptureOptions) => Promise<CommandResponse>
```

Captures a video

| Param         | Type                                                                |
| ------------- | ------------------------------------------------------------------- |
| **`options`** | <code><a href="#videocaptureoptions">VideoCaptureOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### livePreview(...)

```typescript
livePreview(options: LivePreviewOptions) => Promise<void>
```

Starts live preview

| Param         | Type                                                              |
| ------------- | ----------------------------------------------------------------- |
| **`options`** | <code><a href="#livepreviewoptions">LivePreviewOptions</a></code> |

--------------------


### stopLivePreview()

```typescript
stopLivePreview() => Promise<void>
```

Stops live preview

--------------------


### readSettings()

```typescript
readSettings() => Promise<CommandResponse>
```

Reads camera settings

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### setSettings(...)

```typescript
setSettings(options: any) => Promise<CommandResponse>
```

Sets camera settings

| Param         | Type             |
| ------------- | ---------------- |
| **`options`** | <code>any</code> |

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### Interfaces


#### CameraInfo

| Prop                  | Type                                                        |
| --------------------- | ----------------------------------------------------------- |
| **`manufacturer`**    | <code>string</code>                                         |
| **`model`**           | <code>string</code>                                         |
| **`serialNumber`**    | <code>string</code>                                         |
| **`firmwareVersion`** | <code>string</code>                                         |
| **`supportUrl`**      | <code>string</code>                                         |
| **`gps`**             | <code>boolean</code>                                        |
| **`gyro`**            | <code>boolean</code>                                        |
| **`uptime`**          | <code>number</code>                                         |
| **`api`**             | <code>string[]</code>                                       |
| **`endpoints`**       | <code>{ httpPort: number; httpUpdatesPort: number; }</code> |
| **`apiLevel`**        | <code>number[]</code>                                       |


#### InitializeOptions

| Prop               | Type                                                                                          |
| ------------------ | --------------------------------------------------------------------------------------------- |
| **`cameraUrl`**    | <code>string</code>                                                                           |
| **`language`**     | <code>'en-US' \| 'en-GB' \| 'ja' \| 'fr' \| 'de' \| 'zh-TW' \| 'zh-CN' \| 'it' \| 'ko'</code> |
| **`setDateTime`**  | <code>boolean</code>                                                                          |
| **`sleepDelay`**   | <code>number</code>                                                                           |
| **`shutterSound`** | <code>number</code>                                                                           |


#### CommandResponse

| Prop          | Type                                            |
| ------------- | ----------------------------------------------- |
| **`name`**    | <code>string</code>                             |
| **`state`**   | <code>string</code>                             |
| **`results`** | <code>any</code>                                |
| **`error`**   | <code>{ code: string; message: string; }</code> |


#### PictureCaptureOptions

| Prop                  | Type                         |
| --------------------- | ---------------------------- |
| **`fileFormat`**      | <code>'jpeg' \| 'raw'</code> |
| **`exposureProgram`** | <code>number</code>          |
| **`iso`**             | <code>number</code>          |
| **`shutterSpeed`**    | <code>number</code>          |


#### VideoCaptureOptions

| Prop             | Type                      |
| ---------------- | ------------------------- |
| **`resolution`** | <code>'4K' \| '2K'</code> |
| **`frameRate`**  | <code>number</code>       |
| **`bitrate`**    | <code>number</code>       |


#### LivePreviewOptions

| Prop                 | Type                 |
| -------------------- | -------------------- |
| **`displayInFront`** | <code>boolean</code> |

</docgen-api>
