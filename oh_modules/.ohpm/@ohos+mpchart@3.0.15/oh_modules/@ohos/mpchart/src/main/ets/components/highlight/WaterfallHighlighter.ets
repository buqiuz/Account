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

import WaterfallData from '../data/WaterfallData';
import WaterfallDataProvider from '../interfaces/dataprovider/WaterfallDataProvider';
import MPPointD from '../utils/MPPointD';
import ChartHighlighter from './ChartHighlighter';
import Highlight from './Highlight';

export default class WaterfallHighlighter extends ChartHighlighter<WaterfallDataProvider> {
  constructor(chart: WaterfallDataProvider) {
    super(chart);
  }

  public getHighlight(x: number, y: number): Highlight | null {
    let high: Highlight | null = super.getHighlight(x, y);

    if (high == null) {
      return null;
    }

    let pos: MPPointD = super.getValsForTouch(x, y);

    let waterfallData: WaterfallData | null = this.mChart.getWaterfallData();
    if (!waterfallData) {
      return null;
    }

    MPPointD.recycleInstance(pos);

    return high;
  }

  protected getDistance(x1: number, y1: number, x2: number, y2: number): number {
    return Math.abs(x1 - x2);
  }

  protected getData(): WaterfallData | null
  {
    return this.mChart.getWaterfallData();
  }
}
