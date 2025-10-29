# ricoh360-camera

<a href="https://capgo.app/"><img src='https://raw.githubusercontent.com/Cap-go/capgo/main/assets/capgo_banner.png' alt='Capgo - Instant updates for capacitor'/></a>

<div align="center">
  <h2><a href="https://capgo.app/?ref=plugin_ricoh360_camera_plugin"> ➡️ Get Instant updates for your App with Capgo</a></h2>
  <h2><a href="https://capgo.app/consulting/?ref=plugin_ricoh360_camera_plugin"> Missing a feature? We’ll build the plugin for you 💪</a></h2>
</div>

Provides an SDK for the Ricoh360 cameras for Capacitor

## Documentation

The most complete doc is available here: https://capgo.app/docs/plugins/ricoh360-camera-plugin/

## Install

```bash
npm install ricoh360-camera
npx cap sync
```

## API

<docgen-index>

* [`initialize(...)`](#initialize)
* [`getCameraAsset(...)`](#getcameraasset)
* [`listFiles(...)`](#listfiles)
* [`capturePicture()`](#capturepicture)
* [`captureVideo(...)`](#capturevideo)
* [`livePreview(...)`](#livepreview)
* [`stopLivePreview()`](#stoplivepreview)
* [`readSettings(...)`](#readsettings)
* [`setSettings(...)`](#setsettings)
* [`sendCommand(...)`](#sendcommand)
* [`getPluginVersion()`](#getpluginversion)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initialize(...)

```typescript
initialize(options: InitializeOptions) => Promise<CommandResponse>
```

Initializes the SDK with camera URL

| Param         | Type                                                            |
| ------------- | --------------------------------------------------------------- |
| **`options`** | <code><a href="#initializeoptions">InitializeOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### getCameraAsset(...)

```typescript
getCameraAsset(options: GetCameraAssetOptions) => Promise<GetCameraAssetResponse>
```

Retrieves a camera asset from a URL and returns it as base64

| Param         | Type                                                                    | Description                                       |
| ------------- | ----------------------------------------------------------------------- | ------------------------------------------------- |
| **`options`** | <code><a href="#getcameraassetoptions">GetCameraAssetOptions</a></code> | Object containing the URL to fetch the asset from |

**Returns:** <code>Promise&lt;<a href="#getcameraassetresponse">GetCameraAssetResponse</a>&gt;</code>

--------------------


### listFiles(...)

```typescript
listFiles(options?: ListFilesOptions | undefined) => Promise<ListFilesResponse>
```

Lists files stored on the camera

| Param         | Type                                                          | Description                                        |
| ------------- | ------------------------------------------------------------- | -------------------------------------------------- |
| **`options`** | <code><a href="#listfilesoptions">ListFilesOptions</a></code> | Optional parameters to filter and paginate results |

**Returns:** <code>Promise&lt;<a href="#listfilesresponse">ListFilesResponse</a>&gt;</code>

--------------------


### capturePicture()

```typescript
capturePicture() => Promise<CommandResponse>
```

Captures a picture

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
livePreview(options: LivePreviewOptions) => Promise<CommandResponse>
```

Starts live preview

| Param         | Type                                                              |
| ------------- | ----------------------------------------------------------------- |
| **`options`** | <code><a href="#livepreviewoptions">LivePreviewOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### stopLivePreview()

```typescript
stopLivePreview() => Promise<CommandResponse>
```

Stops live preview

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### readSettings(...)

```typescript
readSettings(options: { options: string[]; }) => Promise<CommandResponse>
```

Reads camera settings

| Param         | Type                                | Description                               |
| ------------- | ----------------------------------- | ----------------------------------------- |
| **`options`** | <code>{ options: string[]; }</code> | Array of option names to read from camera |

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### setSettings(...)

```typescript
setSettings(options: { options: Record<string, any>; }) => Promise<CommandResponse>
```

Sets camera settings

| Param         | Type                                                                       | Description                              |
| ------------- | -------------------------------------------------------------------------- | ---------------------------------------- |
| **`options`** | <code>{ options: <a href="#record">Record</a>&lt;string, any&gt;; }</code> | Object containing camera settings to set |

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### sendCommand(...)

```typescript
sendCommand(options: { endpoint: string; payload: Record<string, any>; }) => Promise<CommandResponse>
```

Send raw command to camera

| Param         | Type                                                                                         |
| ------------- | -------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ endpoint: string; payload: <a href="#record">Record</a>&lt;string, any&gt;; }</code> |

**Returns:** <code>Promise&lt;<a href="#commandresponse">CommandResponse</a>&gt;</code>

--------------------


### getPluginVersion()

```typescript
getPluginVersion() => Promise<{ version: string; }>
```

Get the native Capacitor plugin version

**Returns:** <code>Promise&lt;{ version: string; }&gt;</code>

--------------------


### Interfaces


#### CommandResponse

| Prop           | Type                |
| -------------- | ------------------- |
| **`session`**  | <code>string</code> |
| **`info`**     | <code>string</code> |
| **`preview`**  | <code>string</code> |
| **`picture`**  | <code>string</code> |
| **`settings`** | <code>string</code> |


#### InitializeOptions

| Prop      | Type                |
| --------- | ------------------- |
| **`url`** | <code>string</code> |


#### GetCameraAssetResponse

| Prop             | Type                |
| ---------------- | ------------------- |
| **`statusCode`** | <code>number</code> |
| **`data`**       | <code>string</code> |
| **`filePath`**   | <code>string</code> |


#### GetCameraAssetOptions

| Prop             | Type                 |
| ---------------- | -------------------- |
| **`url`**        | <code>string</code>  |
| **`saveToFile`** | <code>boolean</code> |


#### ListFilesResponse

| Prop          | Type                                                                                                                                                                                                                                                  |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`results`** | <code>{ entries: { name: string; fileUrl: string; size: number; dateTimeZone: string; width?: number; height?: number; previewUrl?: string; _projectionType?: string; isProcessed?: boolean; _thumbSize?: number; }[]; totalEntries: number; }</code> |


#### ListFilesOptions

| Prop                | Type                                     |
| ------------------- | ---------------------------------------- |
| **`fileType`**      | <code>'all' \| 'image' \| 'video'</code> |
| **`startPosition`** | <code>number</code>                      |
| **`entryCount`**    | <code>number</code>                      |
| **`maxThumbSize`**  | <code>number</code>                      |
| **`_detail`**       | <code>boolean</code>                     |


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
| **`cropPreview`**    | <code>boolean</code> |


### Type Aliases


#### Record

Construct a type with a set of properties K of type T

<code>{ [P in K]: T; }</code>

</docgen-api>
