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

import LineData from '../data/LineData';
import LineDataProvider from '../interfaces/dataprovider/LineDataProvider';
import ILineDataSet from '../interfaces/datasets/ILineDataSet';
import IFillFormatter from './IFillFormatter';

/**
 * Default formatter that calculates the position of the filled line.
 *
 *
 */
export default class DefaultFillFormatter implements IFillFormatter {
  public getFillLinePosition(dataSet: ILineDataSet, dataProvider: LineDataProvider): number {

    let fillMin: number = 0;
    let chartMaxY: number = dataProvider.getYChartMax();
    let chartMinY: number = dataProvider.getYChartMin();

    let data: LineData | null = dataProvider.getLineData();

    if (dataSet.getYMax() > 0 && dataSet.getYMin() < 0) {
      fillMin = 0;
    } else {

      let max: number;
      let min: number;

      if (data && data.getYMax() > 0) {
        max = 0;
      } else {
        max = chartMaxY;
      }
      if (data && data.getYMin() < 0) {
        min = 0;
      }
      else {
        min = chartMinY;
      }

      fillMin = dataSet.getYMin() >= 0 ? min : max;
    }

    return fillMin;
  }
}