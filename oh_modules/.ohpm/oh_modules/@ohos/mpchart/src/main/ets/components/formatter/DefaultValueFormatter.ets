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

import IValueFormatter from './IValueFormatter';
import EntryOhos from '../data/EntryOhos';
import ViewPortHandler from '../utils/ViewPortHandler';

/**
 * Default formatter used for formatting values inside the chart. Uses a DecimalFormat with
 * pre-calculated number of digits (depending on max and min value).
 *
 *
 */
export default class DefaultValueFormatter implements IValueFormatter {
  /**
   * DecimalFormat for formatting
   */
  //protected  mFormat:DecimalFormat;

  protected mDecimalDigits: number = 0;

  /**
   * Constructor that specifies to how many digits the value should be
   * formatted.
   *
   * @param digits
   */
  constructor(digits: number) {
    this.setup(digits);
  }

  /**
   * Sets up the formatter with a given number of decimal digits.
   *
   * @param digits
   */
  public setup(digits: number): void {

    this.mDecimalDigits = digits;
  }

  public getFormattedValue(value: number, entry: EntryOhos, dataSetIndex: number, viewPortHandler: ViewPortHandler): string {

    // put more logic here ...
    // avoid memory allocations here (for performance reasons)

    return (Math.round(value * 10) / 10).toString();
  }

  /**
   * Returns the number of decimal digits this formatter uses.
   *
   * @return
   */
  public getDecimalDigits(): number {
    return this.mDecimalDigits;
  }
}
