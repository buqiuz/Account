/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export default abstract class AbstractBuffer<T> {
  /** index in the buffer */
  protected index: number = 0;
  /** float-buffer that holds the data points to draw, order: x,y,x,y,... */
  public buffer: number[] = [];
  /** animation phase x-axis */
  protected phaseX: number = 1;
  /** animation phase y-axis */
  protected phaseY: number = 1;
  /** indicates from which x-index the visible data begins */
  protected mFrom: number = 0;
  /** indicates to which x-index the visible data ranges */
  protected mTo: number = 0;

  /**
   * Initialization with buffer-size.
   *
   * @param size
   */
  constructor(size: number) {
    this.index = 0;
    for (let i = 0; i < size; i++) {
      this.buffer = new Array<number>();
    }
  }

  /** limits the drawing on the x-axis */
  public limitFrom(from: number): void {
    if (from < 0)
      from = 0;
    this.mFrom = from;
  }

  /** limits the drawing on the x-axis */
  public limitTo(to: number): void {
    if (to < 0)
      to = 0;
    this.mTo = to;
  }

  /**
   * Resets the buffer index to 0 and makes the buffer reusable.
   */
  public reset(): void {
    this.index = 0;
  }

  /**
   * Returns the size (length) of the buffer array.
   *
   * @return
   */
  public size(): number {
    return this.buffer.length;
  }

  /**
   * Set the phases used for animations.
   *
   * @param phaseX
   * @param phaseY
   */
  public setPhases(phaseX: number, phaseY: number): void {
    this.phaseX = phaseX;
    this.phaseY = phaseY;
  }

  /**
   * Builds up the buffer with the provided data and resets the buffer-index
   * after feed-completion. This needs to run FAST.
   *
   * @param data
   */
  public abstract feed(data: T): void;
}
