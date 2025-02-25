/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

import BarBuffer from './BarBuffer';
import IBarDataSet from '../interfaces/datasets/IBarDataSet';
import WaterfallEntry from '../data/WaterfallEntry';

export default class WaterfallBuffer extends BarBuffer {
  private arrayTop: Array<number> = [];
  private arrayBottom: Array<number> = [];

  public getArrayTop(): Array<number> {
    return this.arrayTop;
  }

  public getArrayBottom(): Array<number> {
    return this.arrayBottom;
  }

  public feed(data: IBarDataSet): void {

    let size: number = data.getEntryCount() * this.phaseX;
    let barWidthHalf: number = this.mBarWidth / 2;
    this.arrayTop = [];
    this.arrayBottom = [];

    for (let i = 0; i < size; i++) {

      let e: WaterfallEntry | null = data.getEntryForIndex(i) as WaterfallEntry;

      if (e == null)
        continue;

      let x: number = e.getX();
      let y1: number = e.getMinY();
      let y2: number = e.getMaxY();

      let minY = Math.max(y1, y2);
      let maxY = Math.min(y1, y2);

      let bottom = this.mInverted ? maxY : minY;
      let top = this.mInverted ? minY : maxY;
      this.arrayTop.push(e.getMaxY());
      this.arrayBottom.push(e.getMinY());
      this.addWaterfall(x - barWidthHalf, top * this.phaseY, x + barWidthHalf, bottom * this.phaseY);
    }

    this.reset();
  }

  protected addWaterfall(left: number, top: number, right: number, bottom: number): void {
    this.buffer[this.index++] = left;
    this.buffer[this.index++] = top;
    this.buffer[this.index++] = right;
    this.buffer[this.index++] = bottom;
  }
}
