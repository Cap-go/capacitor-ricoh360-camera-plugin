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
* [`capturePicture()`](#capturepicture)
* [`captureVideo(...)`](#capturevideo)
* [`livePreview(...)`](#livepreview)
* [`stopLivePreview()`](#stoplivepreview)
* [`readSettings(...)`](#readsettings)
* [`setSettings(...)`](#setsettings)
* [`sendCommand(...)`](#sendcommand)
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


### Type Aliases


#### Record

Construct a type with a set of properties K of type T

<code>{ [P in K]: T; }</code>

</docgen-api>
