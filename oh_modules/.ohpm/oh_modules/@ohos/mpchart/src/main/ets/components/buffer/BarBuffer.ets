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

import AbstractBuffer from './AbstractBuffer';
import BarEntry from '../data/BarEntry';
import IBarDataSet from '../interfaces/datasets/IBarDataSet';

export default class BarBuffer extends AbstractBuffer<IBarDataSet> {
  protected mDataSetIndex: number = 0;
  protected mDataSetCount: number = 1;
  protected mContainsStacks: boolean = false;
  protected mInverted: boolean = false;
  /** width of the bar on the x-axis, in values (not pixels) */
  protected mBarWidth: number = 1;

  constructor(size: number, dataSetCount: number, containsStacks: boolean) {
    super(size);
    this.mDataSetCount = dataSetCount;
    this.mContainsStacks = containsStacks;
  }

  public setBarWidth(barWidth: number): void {
    this.mBarWidth = barWidth;
  }

  public setDataSet(index: number): void {
    this.mDataSetIndex = index;
  }

  public setInverted(inverted: boolean): void {
    this.mInverted = inverted;
  }

  protected addBar(left: number, top: number, right: number, bottom: number): void {

    this.buffer[this.index++] = left;
    this.buffer[this.index++] = top;
    this.buffer[this.index++] = right;
    this.buffer[this.index++] = bottom;
  }

  public feed(data: IBarDataSet): void {

    let size: number = data.getEntryCount() * this.phaseX;
    let barWidthHalf: number = this.mBarWidth / 2;

    for (let i = 0; i < size; i++) {

      let e: BarEntry | null = data.getEntryForIndex(i);

      if (e == null)
        continue;

      let x: number = e.getX();
      let y: number = e.getY();
      let values: number[] | null = e.getYVals();

      if (!this.mContainsStacks || values == null) {

        let left: number = x - barWidthHalf;
        let right: number = x + barWidthHalf;
        let bottom: number = 0;
        let top: number = 0;

        if (this.mInverted) {
          bottom = y >= 0 ? y : 0;
          top = y <= 0 ? y : 0;
        } else {
          top = y >= 0 ? y : 0;
          bottom = y <= 0 ? y : 0;
        }

        // multiply the height of the rect with the phase
        if (top > 0)
          top *= this.phaseY;
        else
          bottom *= this.phaseY;

        this.addBar(left, top, right, bottom);

      } else {

        let posY: number = 0;
        let negY: number = -e.getNegativeSum();
        let yStart: number = 0;

        // fill the stack
        for (let k = 0; k < values.length; k++) {

          let value: number = values[k];

          if (value == 0.0 && (posY == 0.0 || negY == 0.0)) {
            // Take care of the situation of a 0.0 value, which overlaps a non-zero bar
            y = value;
            yStart = y;
          } else if (value >= 0.0) {
            y = posY;
            yStart = posY + value;
            posY = yStart;
          } else {
            y = negY;
            yStart = negY + Math.abs(value);
            negY += Math.abs(value);
          }

          let left: number = x - barWidthHalf;
          let right: number = x + barWidthHalf;
          let bottom: number = 0;
          let top: number = 0;

          if (this.mInverted) {
            bottom = y >= yStart ? y : yStart;
            top = y <= yStart ? y : yStart;
          } else {
            top = y >= yStart ? y : yStart;
            bottom = y <= yStart ? y : yStart;
          }

          // multiply the height of the rect with the phase
          top *= this.phaseY;
          bottom *= this.phaseY;

          this.addBar(left, top, right, bottom);
        }
      }
    }

    this.reset();
  }
}
