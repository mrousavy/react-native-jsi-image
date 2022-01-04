export type Orientation = 'up' | 'down' | 'left' | 'right';

export interface Image {
  /**
   * The Image's width in pixels.
   */
  readonly width: number;
  /**
   * The Image's height in pixels.
   */
  readonly height: number;
  /**
   * The Image's scale factor. For most images, this is `1.0`.
   */
  readonly scale: number;
  /**
   * Whether the image is horizontally flipped ("mirrored"), or not.
   */
  readonly isFlipped: boolean;
  /**
   * The Image's orientation.
   */
  readonly orientation: Orientation;

  /**
   * The Image's PNG data.
   *
   * See [`pngData`](https://developer.apple.com/documentation/uikit/uiimage/1624096-pngdata) for more information.
   */
  readonly data: Uint8Array;
  /**
   * Horizontally flips ("mirror") the Image and returns the new copy.
   *
   * @example
   * ```ts
   * console.log(image.isFlipped) // false
   * const flippedImage = image.flip()
   * console.log(flippedImage.isFlipped) // true
   * ```
   */
  flip(): Image;
  /**
   * Writes the Image to the given file path.
   * @param filePath The file path to save the Image to. File extension should either be `.png` or `.jpg`.
   *
   * @example
   * ```ts
   * await image.save('file:///Users/Marc/profile-picture.png')
   * ```
   */
  save(filePath: string): Promise<void>;
  /**
   * Returns a string-representation of the Image useful for debugging.
   */
  toString(): string;
}
