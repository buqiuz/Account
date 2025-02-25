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

import { FontFamily } from '../data/Paint';
import Utils from '../utils/Utils';

/**
 * This class encapsulates everything both Axis, Legend and LimitLines have in common.
 *
 */
export default abstract class ComponentBase {
  /**
   * flag that indicates if this axis / legend is enabled or not
   */
  protected mEnabled: boolean = true;
  /**
   * the offset in pixels this component has on the x-axis
   */
  protected mXOffset: number = 5;
  /**
   * the offset in pixels this component has on the Y-axis
   */
  protected mYOffset: number = 5;
  /**
   * the typeface used for the labels
   */
  protected mTypeface: FontFamily /*Typeface*/
    = '';
  /**
   * the text size of the labels
   */
  protected mTextSize: number = 10;
  /**
   * the text color to use for the labels
   */
  protected mTextColor: string | number | CanvasGradient | CanvasPattern = Color.Black;

  constructor() {

  }

  /**
   * Returns the used offset on the x-axis for drawing the axis or legend
   * labels. This offset is applied before and after the label.
   *
   * @return
   */
  public getXOffset(): number {
    return this.mXOffset;
  }

  /**
   * Sets the used x-axis offset for the labels on this axis.
   *
   * @param xOffset
   */
  public setXOffset(xOffset: number): void {
    this.mXOffset = Utils.handleDataValues(xOffset);
  }

  /**
   * Returns the used offset on the x-axis for drawing the axis labels. This
   * offset is applied before and after the label.
   *
   * @return
   */
  public getYOffset(): number {
    return this.mYOffset;
  }

  /**
   * Sets the used y-axis offset for the labels on this axis. For the legend,
   * higher offset means the legend as a whole will be placed further away
   * from the top.
   *
   * @param yOffset
   */
  public setYOffset(yOffset: number): void {
    this.mYOffset = Utils.handleDataValues(yOffset);
  }

  // public  setOriginYOffset(yOffset:number):void {
  //     this.mYOffset = yOffset;
  // }

  /**
   * returns the Typeface used for the labels, returns null if none is set
   *
   * @return
   */
  public getTypeface(): FontFamily /*Typeface*/
  {
    return this.mTypeface;
  }

  /**
   * sets a specific Typeface for the labels
   *
   * @param tf
   */
  public setTypeface(tf: FontFamily /*Typeface*/
  ): void {
    this.mTypeface = tf;
  }

  /**
   * sets the size of the label text in density pixels min = 6f, max = 24f, default
   * 10f
   *
   * @param size the text size, in vp
   */
  public setTextSize(size: number): void {

    if (size > 48)
      size = 48;
    if (size < 6)
      size = 6;

    this.mTextSize = size;
  }

  /**
   * returns the text size that is currently set for the labels, in vp
   *
   * @return
   */
  public getTextSize(): number {
    return this.mTextSize;
  }


  /**
   * Sets the text color to use for the labels. Make sure to use
   * getResources().getColor(...) when using a color from the resources.
   *
   * @param color
   */
  public setTextColor(color: string | number | CanvasGradient | CanvasPattern): void {
    this.mTextColor = color;
  }

  /**
   * Returns the text color that is set for the labels.
   *
   * @return
   */
  public getTextColor(): string | number | CanvasGradient | CanvasPattern {
    return this.mTextColor;
  }

  /**
   * Set this to true if this component should be enabled (should be drawn),
   * false if not. If disabled, nothing of this component will be drawn.
   * Default: true
   *
   * @param enabled
   */
  public setEnabled(enabled: boolean): void {
    this.mEnabled = enabled;
  }

  /**
   * Returns true if this component is enabled (should be drawn), false if not.
   *
   * @return
   */
  public isEnabled(): boolean {
    return this.mEnabled;
  }
}
