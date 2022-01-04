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
   * Whether the image is mirrored/horizontally flipped, or not.
   */
  readonly isMirrored: boolean;
  /**
   * The Image's orientation.
   */
  readonly orientation: Orientation;
}
