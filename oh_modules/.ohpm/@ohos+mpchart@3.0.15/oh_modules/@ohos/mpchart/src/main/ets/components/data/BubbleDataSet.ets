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

import IBubbleDataSet from '../interfaces/datasets/IBubbleDataSet';
import { JArrayList } from '../utils/JArrayList';
import Utils from '../utils/Utils';
import BarLineScatterCandleBubbleDataSet from './BarLineScatterCandleBubbleDataSet';
import BubbleEntry from './BubbleEntry';
import { DataSet } from './DataSet';

export default class BubbleDataSet extends BarLineScatterCandleBubbleDataSet<BubbleEntry> implements IBubbleDataSet {
  static mMaxSize: number = 0;
  protected mNormalizeSize: boolean = true;
  private mHighlightCircleWidth: number = 2.5;

  constructor(yVals: JArrayList<BubbleEntry>, label: string) {
    super(yVals, label);
  }

  // @Override
  public setHighlightCircleWidth(width: number): void {
    this.mHighlightCircleWidth = Utils.handleDataValues(width);
  }

  // @Override
  public getHighlightCircleWidth(): number {
    return this.mHighlightCircleWidth;
  }

  public myCalcMinMax(e ?: BubbleEntry): void {
    super.myCalcMinMax(e);
    if (e) {
      let size: number = e.getSize();
      if (size > BubbleDataSet.mMaxSize) {
        BubbleDataSet.mMaxSize = size;
      }
    }
  }

  // @Override
  public copy(): DataSet<BubbleEntry> {
    let entries: JArrayList<BubbleEntry> = new JArrayList<BubbleEntry>();
    if (this.mEntries != null) {
      for (let i: number = 0; i < this.mEntries.size(); i++) {
        entries.add(this.mEntries.get(i).copy());
      }
    }
    let copied = new BubbleDataSet(entries, this.getLabel());
    this.copyDataSet(copied);
    return copied;
  }

  protected copyDataSet(bubbleDataSet: BubbleDataSet): void {
    bubbleDataSet.mHighlightCircleWidth = this.mHighlightCircleWidth;
    bubbleDataSet.mNormalizeSize = this.mNormalizeSize;
  }

  // @Override
  public getMaxSize(): number {
    return BubbleDataSet.mMaxSize;
  }

  // @Override
  public isNormalizeSizeEnabled(): boolean {
    return this.mNormalizeSize;
  }

  public setNormalizeSizeEnabled(normalizeSize: boolean): void {
    this.mNormalizeSize = normalizeSize;
  }
}
