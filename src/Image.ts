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
   * Horizontally flips ("mirror") the Image and returns the new copy.
   */
  flip(): Image;
}
