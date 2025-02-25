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

import ChartPixelMap from './ChartPixelMap';

export default abstract class BaseEntry {
  /** the y value */
  private y: number = 0;
  /** optional spot for additional data this Entry represents */
  private mData: Object | null = null;
  /** optional icon image */
  private mIcon: ChartPixelMap | null = null;

  constructor(y?: number, icon?: ChartPixelMap, data?: Object) {
    if (y) {
      this.y = y;
    }
    if (icon) {
      this.mIcon = icon;
    }
    if (data) {
      this.mData = data;
    }
  }

  /**
   * Returns the y value of this Entry.
   *
   * @return
   */
  public getY(): number {
    return this.y;
  }

  /**
   * Sets the icon drawable
   *
   * @param icon
   */
  public setIcon(icon: ChartPixelMap): void {
    this.mIcon = icon;
  }

  /**
   * Returns the icon of this Entry.
   *
   * @return
   */
  public getIcon(): ChartPixelMap | null {
    return this.mIcon;
  }

  /**
   * Sets the y-value for the Entry.
   *
   * @param y
   */
  public setY(y: number): void {
    this.y = y;
  }

  /**
   * Returns the data, additional information that this Entry represents, or
   * null, if no data has been specified.
   *
   * @return
   */
  public getData(): Object | null {
    return this.mData;
  }

  /**
   * Sets additional data this Entry should represent.
   *
   * @param data
   */
  public setData(data: Object): void {
    this.mData = data;
  }
}
