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

import MPPointF from '../utils/MPPointF';
import Utils from '../utils/Utils';
import ComponentBase from './ComponentBase';

export default class Description extends ComponentBase {
  /**
   * the text used in the description
   */
  private text: string = "Description Label";
  /**
   * the custom position of the description text
   */
  private mPosition: MPPointF | null = null;
  /**
   * the alignment of the description text
   */
  private mTextAlign: CanvasTextAlign = 'right'

  constructor() {
    super();
    // default size
    this.mTextSize = Utils.handleDataValues(8);
  }

  /**
   * Sets the text to be shown as the description.
   *
   * @param text
   */
  public setText(text: string): void {
    this.text = text;
  }

  /**
   * Returns the description text.
   *
   * @return
   */
  public getText(): string {
    return this.text;
  }

  /**
   * Sets a custom position for the description text in pixels on the screen.
   *
   * @param x - xcoordinate
   * @param y - ycoordinate
   */
  public setPosition(x: number, y: number): void {
    if (this.mPosition == null) {
      this.mPosition = MPPointF.getInstance(x, y);
    } else {
      this.mPosition.x = x;
      this.mPosition.y = y;
    }
  }

  /**
   * Returns the customized position of the description, or null if none set.
   *
   * @return
   */
  public getPosition(): MPPointF | null {
    return this.mPosition;
  }

  /**
   * Sets the text alignment of the description text. Default RIGHT.
   *
   * @param align
   */
  public setTextAlign(align: CanvasTextAlign) {
    this.mTextAlign = align;
  }

  /**
   * Returns the text alignment of the description.
   *
   * @return
   */
  public getTextAlign(): CanvasTextAlign {
    return this.mTextAlign;
  }
}
