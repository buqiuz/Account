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

import BarData from '../data/BarData';
import BarEntry from '../data/BarEntry';
import BarDataProvider from '../interfaces/dataprovider/BarDataProvider';
import IBarDataSet from '../interfaces/datasets/IBarDataSet';
import MPPointD from '../utils/MPPointD';
import Transformer from '../utils/Transformer';
import ChartHighlighter from './ChartHighlighter';
import Highlight from './Highlight';
import Range from './Range';

export default class BarHighlighter extends ChartHighlighter<BarDataProvider> {
  constructor(chart: BarDataProvider) {
    super(chart);
  }

  public getHighlight(x: number, y: number): Highlight | null {
    let high: Highlight | null = super.getHighlight(x, y);

    if (high == null) {
      return null;
    }

    let pos: MPPointD = super.getValsForTouch(x, y);

    let barData: BarData | null = this.mChart.getBarData();
    if (!barData) {
      return null;
    }
    let set: IBarDataSet | null = barData.getDataSetByIndex(high.getDataSetIndex());
    if (set && set.isStacked()) {

      return this.getStackedHighlight(high, set, pos.x, pos.y);
    }

    MPPointD.recycleInstance(pos);

    return high;
  }

  /**
   * This method creates the Highlight object that also indicates which value of a stacked BarEntry has been
   * selected.
   *
   * @param high the Highlight to work with looking for stacked values
   * @param set
   * @param xVal
   * @param yVal
   * @return
   */
  public getStackedHighlight(high: Highlight, set: IBarDataSet, xVal: number, yVal: number): Highlight | null {

    let entry: BarEntry | null = set.getEntryForXValue(xVal, yVal);

    if (entry == null)
      return null;

    // not stacked
    if (entry.getYVals() == null) {
      return high;
    } else {
      let ranges: Range[] | null = entry.getRanges();
      if (!ranges) {
        return null;
      }
      if (ranges.length > 0) {
        let stackIndex: number = this.getClosestStackIndex(ranges, yVal);

        let pixels: MPPointD = MPPointD.getInstance(0, 0);
        let transformer: Transformer | null = this.mChart.getTransformer(set.getAxisDependency());
        if (transformer) {
          pixels = transformer.getPixelForValues(high.getX(), ranges[stackIndex].to);
        }

        let stackedHigh: Highlight = new Highlight(
          entry.getX(), entry.getY(),
          high.getDataSetIndex(),
          0,
          stackIndex,
          pixels.x, pixels.y,
          high.getAxis()
        );

        MPPointD.recycleInstance(pixels);

        return stackedHigh;
      }
    }

    return null;
  }

  /**
   * Returns the index of the closest value inside the values array / ranges (stacked barchart) to the value
   * given as
   * a parameter.
   *
   * @param ranges
   * @param value
   * @return
   */
  protected getClosestStackIndex(ranges: Range[], value: number): number {

    if (ranges == null || ranges.length == 0)
      return 0;

    let stackIndex: number = 0;

    for (let range of ranges) {
      if (range.contains(value))
        return stackIndex;
      else
        stackIndex++;
    }

    let length: number = Math.max(ranges.length - 1, 0);

    return (value > ranges[length].to) ? length : 0;
  }

  //    /**
  //     * Splits up the stack-values of the given bar-entry into Range objects.
  //     *
  //     * @param entry
  //     * @return
  //     */
  //    protected Range[] getRanges(BarEntry entry) {
  //
  //        float[] values = entry.getYVals();
  //
  //        if (values == null || values.length == 0)
  //            return new Range[0];
  //
  //        Range[] ranges = new Range[values.length];
  //
  //        float negRemain = -entry.getNegativeSum();
  //        float posRemain = 0f;
  //
  //        for (int i = 0; i < ranges.length; i++) {
  //
  //            float value = values[i];
  //
  //            if (value < 0) {
  //                ranges[i] = new Range(negRemain, negRemain + Math.abs(value));
  //                negRemain += Math.abs(value);
  //            } else {
  //                ranges[i] = new Range(posRemain, posRemain + value);
  //                posRemain += value;
  //            }
  //        }
  //
  //        return ranges;
  //    }

  protected getDistance(x1: number, y1: number, x2: number, y2: number): number {
    return Math.abs(x1 - x2);
  }

  protected getData(): BarData | null /*BarLineScatterCandleBubbleData*/
  {
    return this.mChart.getBarData();
  }
}
