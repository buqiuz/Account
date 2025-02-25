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

import EntryOhos from './EntryOhos'
import { DataSet } from './DataSet'
import IBarLineScatterCandleBubbleDataSet from '../interfaces/datasets/IBarLineScatterCandleBubbleDataSet'
import { JArrayList } from '../utils/JArrayList'

/**
 * Baseclass of all DataSets for Bar-, Line-, Scatter- and CandleStickChart.
 *
 */
export default abstract class BarLineScatterCandleBubbleDataSet<T extends EntryOhos> extends DataSet<T> implements IBarLineScatterCandleBubbleDataSet<T> {
  /**
   * default highlight color
   */
  protected mHighLightColor: number = 0xffbb73;

  constructor(yVals: JArrayList<T> | null, label: string) {
    super(yVals, label);
  }

  /**
   * Sets the color that is used for drawing the highlight indicators. Dont
   * forget to resolve the color using ColorTemplate.colorRgb(...) or Color.Xxx or
   * ChartColor.rgb(...).
   *
   * @param color
   */
  public setHighLightColor(color: number): void {
    this.mHighLightColor = color;
  }

  public getHighLightColor(): number {
    return this.mHighLightColor;
  }

  protected copyTo(barLineScatterCandleBubbleDataSet: BarLineScatterCandleBubbleDataSet<T>): void {
    super.copyTo(barLineScatterCandleBubbleDataSet);
    barLineScatterCandleBubbleDataSet.mHighLightColor = this.mHighLightColor;
  }
}
