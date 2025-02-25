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

import BarEntry from '../data/BarEntry';
import IBarDataSet from '../interfaces/datasets/IBarDataSet';

import BarBuffer from './BarBuffer';

export default class HorizontalBarBuffer extends BarBuffer {
  constructor(size: number, dataSetCount: number, containsStacks: boolean) {
    super(size, dataSetCount, containsStacks);
  }

  feed(data: IBarDataSet) {
    let size: number = data.getEntryCount() * this.phaseX;
    let barWidthHalf = this.mBarWidth / 2;

    for (let i = 0; i < size; i++) {
      let e: BarEntry = data.getEntryForIndex(i);
      if (e == null)
        continue;
      let x: number = e.getX();
      let y: number = e.getY();
      let vals = e.getYVals();

      if (!this.mContainsStacks || vals == null) {
        let bottom = x - barWidthHalf;
        let top = x + barWidthHalf;
        let left: number = 0, right: number = 0;
        if (this.mInverted) {
          left = y >= 0 ? y : 0;
          right = y <= 0 ? y : 0;
        } else {
          right = y >= 0 ? y : 0;
          left = y <= 0 ? y : 0;
        }

        // multiply the height of the rect with the phase
        if (right > 0)
          right *= this.phaseY;
        else
          left *= this.phaseY;

        this.addBar(left, top, right, bottom);
      } else {
        let posY = 0;
        let negY = -e.getNegativeSum();
        let yStart = 0;

        //fill the stack
        for (let k = 0; k < vals.length; k++) {
          let value = vals[k];

          if (value >= 0) {
            y = posY;
            yStart = posY + value;
            posY = yStart;
          } else {
            y = negY;
            yStart = negY + Math.abs(value);
            negY += Math.abs(value);
          }

          let bottom = x - barWidthHalf;
          let top = x + barWidthHalf;
          let left: number = 0, right: number = 0;
          if (this.mInverted) {
            left = y >= yStart ? y : yStart;
            right = y <= yStart ? y : yStart;
          } else {
            right = y >= yStart ? y : yStart;
            left = y <= yStart ? y : yStart;
          }

          // multiply the height of the rect with the phase
          right *= this.phaseY;
          left *= this.phaseY;

          this.addBar(left, top, right, bottom);
        }
      }
    }
    this.reset();
  }
}