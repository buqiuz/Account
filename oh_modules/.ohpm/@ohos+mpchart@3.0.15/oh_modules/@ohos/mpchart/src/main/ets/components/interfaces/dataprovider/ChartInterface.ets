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

import MyRect from '../../data/Rect';
import MPPointF from '../../utils/MPPointF';
import IValueFormatter from '../../formatter/IValueFormatter';
import ChartData from '../../data/ChartData';
import IDataSet from '../datasets/IDataSet';
import EntryOhos from '../../data/EntryOhos';

/**
 * Interface that provides everything there is to know about the dimensions,
 * bounds, and range of the chart.
 */
export default interface ChartInterface {

  /**
   * Returns the minimum x value of the chart, regardless of zoom or translation.
   *
   * @return
   */
  getXChartMin(): number;

  /**
   * Returns the maximum x value of the chart, regardless of zoom or translation.
   *
   * @return
   */
  getXChartMax(): number;

  getXRange(): number;

  /**
   * Returns the minimum y value of the chart, regardless of zoom or translation.
   *
   * @return
   */
  getYChartMin(): number;

  /**
   * Returns the maximum y value of the chart, regardless of zoom or translation.
   *
   * @return
   */
  getYChartMax(): number;

  /**
   * Returns the maximum distance in scren dp a touch can be away from an entry to cause it to get highlighted.
   *
   * @return
   */
  getMaxHighlightDistance(): number;

  getWidth(): number;

  getHeight(): number;

  getCenterOfView(): MPPointF;

  getCenterOffsets(): MPPointF | null;

  getContentRect(): MyRect /*RectF*/
  ;

  getDefaultValueFormatter(): IValueFormatter;

  getData(): ChartData<IDataSet<EntryOhos>> | null;

  getMaxVisibleCount(): number;
}
