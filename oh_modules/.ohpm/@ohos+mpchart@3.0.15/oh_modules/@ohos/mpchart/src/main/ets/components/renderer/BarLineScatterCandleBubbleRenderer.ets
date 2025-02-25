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

import EntryOhos from '../data/EntryOhos';
import { Rounding } from '../data/DataSet';
import ChartAnimator from '../animation/ChartAnimator';
import DataRenderer from './DataRenderer';
import ViewPortHandler from '../utils/ViewPortHandler';
import IBarLineScatterCandleBubbleDataSet from '../interfaces/datasets/IBarLineScatterCandleBubbleDataSet';
import BarLineScatterCandleBubbleDataProvider from '../interfaces/dataprovider/BarLineScatterCandleBubbleDataProvider';
import IDataSet from '../interfaces/datasets/IDataSet';

export class XBounds {
  constructor(animator: ChartAnimator) {
    this.mAnimator = animator;
  }

  /**
   * minimum visible entry index
   */
  public min: number = 0;
  /**
   * maximum visible entry index
   */
  public max: number = 0;
  /**
   * range of visible entry indices
   */
  public range: number = 0;
  public mAnimator: ChartAnimator | null = null;

  /**
   * Calculates the minimum and maximum x values as well as the range between them.
   *
   * @param chart
   * @param dataSet
   */
  public set(chart: BarLineScatterCandleBubbleDataProvider, dataSet: IBarLineScatterCandleBubbleDataSet<EntryOhos>) {
    let phaseX: number = Math.max(0, Math.min(1, (this.mAnimator ? this.mAnimator.getPhaseX() : 1)));

    let low: number = chart.getLowestVisibleX();
    let high: number = chart.getHighestVisibleX();

    let entryFrom: EntryOhos | null = dataSet.getEntryForXValue(low, Number.NaN, Rounding.DOWN);
    let entryTo: EntryOhos | null = dataSet.getEntryForXValue(high, Number.NaN, Rounding.UP);

    if (entryFrom && entryTo) {
      this.min = entryFrom == null ? 0 : dataSet.getEntryIndexByEntry(entryFrom);
      this.max = entryTo == null ? 0 : dataSet.getEntryIndexByEntry(entryTo);
      this.range = Math.floor((this.max - this.min) * phaseX);
    }
  }
}

/**
 * Created by Philipp Jahoda on 09/06/16.
 */
export default abstract class BarLineScatterCandleBubbleRenderer extends DataRenderer {
  /**
   * buffer for storing the current minimum and maximum visible x
   */
  protected mXBounds: XBounds | null = null;

  constructor(animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
    if (this.mAnimator) {
      this.mXBounds = new XBounds(this.mAnimator);
    }
  }

  /**
   * Returns true if the DataSet values should be drawn, false if not.
   *
   * @param set
   * @return
   */
  protected shouldDrawValues(dataSet: IDataSet<EntryOhos>): boolean {
    return dataSet.isVisible() && (dataSet.isDrawValuesEnabled() || dataSet.isDrawIconsEnabled());
  }

  /**
   * Checks if the provided entry object is in bounds for drawing considering the current animation phase.
   *
   * @param e
   * @param set
   * @return
   */
  protected isInBoundsX(e: EntryOhos, dataSet: IBarLineScatterCandleBubbleDataSet<EntryOhos>): boolean {

    if (e == null)
      return false;

    let entryIndex = dataSet.getEntryIndexByEntry(e);

    if (e == null || entryIndex >= dataSet.getEntryCount() * (this.mAnimator ? this.mAnimator.getPhaseX() : 1)) {
      return false;
    } else {
      return true;
    }
  }
}


