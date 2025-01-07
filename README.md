# richon360-camera

Provides an SDK for the Richon360 cameras for Capacitor

## Install

```bash
npm install richon360-camera
npx cap sync
```

## API

<docgen-index>

* [`initialize(...)`](#initialize)
* [`capturePicture(...)`](#capturepicture)
* [`captureVideo(...)`](#capturevideo)
* [`livePreview()`](#livepreview)
* [`stopLivePreview()`](#stoplivepreview)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initialize(...)

```typescript
initialize(options: InitializeOptions) => Promise<void>
```

Initializes the SDK

| Param         | Type                                                            |
| ------------- | --------------------------------------------------------------- |
| **`options`** | <code><a href="#initializeoptions">InitializeOptions</a></code> |

--------------------


### capturePicture(...)

```typescript
capturePicture(options: PictureCaptureOptions) => Promise<void>
```

| Param         | Type                                                                    |
| ------------- | ----------------------------------------------------------------------- |
| **`options`** | <code><a href="#picturecaptureoptions">PictureCaptureOptions</a></code> |

--------------------


### captureVideo(...)

```typescript
captureVideo(options: VideoCaptureOptions) => Promise<void>
```

| Param         | Type                                                                |
| ------------- | ------------------------------------------------------------------- |
| **`options`** | <code><a href="#videocaptureoptions">VideoCaptureOptions</a></code> |

--------------------


### livePreview()

```typescript
livePreview() => Promise<void>
```

--------------------


### stopLivePreview()

```typescript
stopLivePreview() => Promise<void>
```

--------------------


### Interfaces


#### InitializeOptions

| Prop               | Type                                                                                          |
| ------------------ | --------------------------------------------------------------------------------------------- |
| **`cameraUrl`**    | <code>string</code>                                                                           |
| **`language`**     | <code>'en-US' \| 'en-GB' \| 'ja' \| 'fr' \| 'de' \| 'zh-TW' \| 'zh-CN' \| 'it' \| 'ko'</code> |
| **`setDateTime`**  | <code>boolean</code>                                                                          |
| **`sleepDelay`**   | <code>number</code>                                                                           |
| **`shutterSound`** | <code>number</code>                                                                           |


#### PictureCaptureOptions


#### VideoCaptureOptions

</docgen-api>
