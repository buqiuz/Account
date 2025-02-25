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

import Utils from '../utils/Utils';
import BaseEntry from './BaseEntry';
import ChartPixelMap from './ChartPixelMap';

/**
 * Class representing one entry in the chart. Might contain multiple values.
 * Might only contain a single value depending on the used constructor.
 *
 */
export default class EntryOhos extends BaseEntry {
  private x: number = 0.0;

  constructor(x?: number, y?: number, icon?: ChartPixelMap, data?: Object) {
    super(y, icon, data);
    this.x = x ? x : 0;
  }

  /**
   * Returns the x-value of this Entry object.
   *
   * @return
   */
  public getX(): number {
    return this.x;
  }

  /**
   * Sets the x-value of this Entry object.
   *
   * @param x
   */
  public setX(x: number): void {
    this.x = x;
  }

  /**
   * returns an exact copy of the entry
   *
   * @return
   */
  public copy(): EntryOhos {
    let data: Object | null = this.getData();
    if (data === null) {
      return new EntryOhos(this.x, this.getY());
    } else {
      return new EntryOhos(this.x, this.getY(), undefined, data);
    }
  }

  /**
   * Compares value, xIndex and data of the entries. Returns true if entries
   * are equal in those points, false if not. Does not check by hash-code like
   * it's done by the "equals" method.
   *
   * @param e
   * @return
   */
  public equalTo(e: EntryOhos): boolean {

    if (!e)
      return false;

    if (e.getData() != this.getData())
      return false;

    if (Math.abs(e.x - this.x) > Utils.FLOAT_EPSILON)
      return false;

    if (Math.abs(e.getY() - this.getY()) > Utils.FLOAT_EPSILON)
      return false;

    return true;
  }

  /**
   * returns a string representation of the entry containing x-index and value
   */
  public toString(): String {
    return "Entry, x: " + this.x + " y: " + this.getY();
  }

  public describeContents(): number {
    return 0;
  }
}
