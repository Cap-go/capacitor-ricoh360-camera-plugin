# ricoh360-camera

<a href="https://capgo.app/"><img src='https://raw.githubusercontent.com/Cap-go/capgo/main/assets/capgo_banner.png' alt='Capgo - Instant updates for capacitor'/></a>

<div align="center">
  <h2><a href="https://capgo.app/?ref=plugin"> ➡️ Get Instant updates for your App with Capgo 🚀</a></h2>
  <h2><a href="https://capgo.app/consulting/?ref=plugin"> Fix your annoying bug now, Hire a Capacitor expert 💪</a></h2>
</div>

Provides an SDK for the Ricoh360 cameras for Capacitor

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

| Param         | Type                                | Description                                                    |
| ------------- | ----------------------------------- | -------------------------------------------------------------- |
| **`options`** | <code>{ options: string[]; }</code> | <a href="#array">Array</a> of option names to read from camera |

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


#### Array

| Prop         | Type                | Description                                                                                            |
| ------------ | ------------------- | ------------------------------------------------------------------------------------------------------ |
| **`length`** | <code>number</code> | Gets or sets the length of the array. This is a number one higher than the highest index in the array. |

| Method             | Signature                                                                                                                     | Description                                                                                                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **toString**       | () =&gt; string                                                                                                               | Returns a string representation of an array.                                                                                                                                                                                                |
| **toLocaleString** | () =&gt; string                                                                                                               | Returns a string representation of an array. The elements are converted to string using their toLocalString methods.                                                                                                                        |
| **pop**            | () =&gt; T \| undefined                                                                                                       | Removes the last element from an array and returns it. If the array is empty, undefined is returned and the array is not modified.                                                                                                          |
| **push**           | (...items: T[]) =&gt; number                                                                                                  | Appends new elements to the end of an array, and returns the new length of the array.                                                                                                                                                       |
| **concat**         | (...items: <a href="#concatarray">ConcatArray</a>&lt;T&gt;[]) =&gt; T[]                                                       | Combines two or more arrays. This method returns a new array without modifying any existing arrays.                                                                                                                                         |
| **concat**         | (...items: (T \| <a href="#concatarray">ConcatArray</a>&lt;T&gt;)[]) =&gt; T[]                                                | Combines two or more arrays. This method returns a new array without modifying any existing arrays.                                                                                                                                         |
| **join**           | (separator?: string \| undefined) =&gt; string                                                                                | Adds all the elements of an array into a string, separated by the specified separator string.                                                                                                                                               |
| **reverse**        | () =&gt; T[]                                                                                                                  | Reverses the elements in an array in place. This method mutates the array and returns a reference to the same array.                                                                                                                        |
| **shift**          | () =&gt; T \| undefined                                                                                                       | Removes the first element from an array and returns it. If the array is empty, undefined is returned and the array is not modified.                                                                                                         |
| **slice**          | (start?: number \| undefined, end?: number \| undefined) =&gt; T[]                                                            | Returns a copy of a section of an array. For both start and end, a negative index can be used to indicate an offset from the end of the array. For example, -2 refers to the second to last element of the array.                           |
| **sort**           | (compareFn?: ((a: T, b: T) =&gt; number) \| undefined) =&gt; this                                                             | Sorts an array in place. This method mutates the array and returns a reference to the same array.                                                                                                                                           |
| **splice**         | (start: number, deleteCount?: number \| undefined) =&gt; T[]                                                                  | Removes elements from an array and, if necessary, inserts new elements in their place, returning the deleted elements.                                                                                                                      |
| **splice**         | (start: number, deleteCount: number, ...items: T[]) =&gt; T[]                                                                 | Removes elements from an array and, if necessary, inserts new elements in their place, returning the deleted elements.                                                                                                                      |
| **unshift**        | (...items: T[]) =&gt; number                                                                                                  | Inserts new elements at the start of an array, and returns the new length of the array.                                                                                                                                                     |
| **indexOf**        | (searchElement: T, fromIndex?: number \| undefined) =&gt; number                                                              | Returns the index of the first occurrence of a value in an array, or -1 if it is not present.                                                                                                                                               |
| **lastIndexOf**    | (searchElement: T, fromIndex?: number \| undefined) =&gt; number                                                              | Returns the index of the last occurrence of a specified value in an array, or -1 if it is not present.                                                                                                                                      |
| **every**          | &lt;S extends T&gt;(predicate: (value: T, index: number, array: T[]) =&gt; value is S, thisArg?: any) =&gt; this is S[]       | Determines whether all the members of an array satisfy the specified test.                                                                                                                                                                  |
| **every**          | (predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any) =&gt; boolean                                 | Determines whether all the members of an array satisfy the specified test.                                                                                                                                                                  |
| **some**           | (predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any) =&gt; boolean                                 | Determines whether the specified callback function returns true for any element of an array.                                                                                                                                                |
| **forEach**        | (callbackfn: (value: T, index: number, array: T[]) =&gt; void, thisArg?: any) =&gt; void                                      | Performs the specified action for each element in an array.                                                                                                                                                                                 |
| **map**            | &lt;U&gt;(callbackfn: (value: T, index: number, array: T[]) =&gt; U, thisArg?: any) =&gt; U[]                                 | Calls a defined callback function on each element of an array, and returns an array that contains the results.                                                                                                                              |
| **filter**         | &lt;S extends T&gt;(predicate: (value: T, index: number, array: T[]) =&gt; value is S, thisArg?: any) =&gt; S[]               | Returns the elements of an array that meet the condition specified in a callback function.                                                                                                                                                  |
| **filter**         | (predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any) =&gt; T[]                                     | Returns the elements of an array that meet the condition specified in a callback function.                                                                                                                                                  |
| **reduce**         | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T) =&gt; T                           | Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.                      |
| **reduce**         | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T, initialValue: T) =&gt; T          |                                                                                                                                                                                                                                             |
| **reduce**         | &lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) =&gt; U, initialValue: U) =&gt; U | Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.                      |
| **reduceRight**    | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T) =&gt; T                           | Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function. |
| **reduceRight**    | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T, initialValue: T) =&gt; T          |                                                                                                                                                                                                                                             |
| **reduceRight**    | &lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) =&gt; U, initialValue: U) =&gt; U | Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function. |


#### ConcatArray

| Prop         | Type                |
| ------------ | ------------------- |
| **`length`** | <code>number</code> |

| Method    | Signature                                                          |
| --------- | ------------------------------------------------------------------ |
| **join**  | (separator?: string \| undefined) =&gt; string                     |
| **slice** | (start?: number \| undefined, end?: number \| undefined) =&gt; T[] |


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
