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

import EntryOhos from '../../data/EntryOhos';
import ILineScatterCandleRadarDataSet from './ILineScatterCandleRadarDataSet';
import ChartPixelMap from '../../data/ChartPixelMap';
import { JArrayList } from '../../utils/JArrayList';
import { ChartColorStop } from '../../data/LineDataSet';

export default interface ILineRadarDataSet<T extends EntryOhos> extends ILineScatterCandleRadarDataSet<T> {

  /**
   * Returns the color that is used for filling the line surface area.
   *
   * @return
   */
  getFillColor(): number;

  /**
   * Returns the drawable used for filling the area below the line.
   *
   * @return
   */
  getFillDrawable(): ChartPixelMap | null;

  /**
   * Returns the alpha value that is used for filling the line surface,
   * default: 85
   *
   * @return
   */
  getFillAlpha(): number;

  /**
   * Returns the stroke-width of the drawn line
   *
   * @return
   */
  getLineWidth(): number;

  /**
   * Returns true if filled drawing is enabled, false if not
   *
   * @return
   */
  isDrawFilledEnabled(): boolean;

  /**
   * Set to true if the DataSet should be drawn filled (surface), and not just
   * as a line, disabling this will give great performance boost. Please note that this method
   * uses the canvas.clipPath(...) method for drawing the filled area.
   * be turned off. Default: false
   *
   * @param enabled
   */
  setDrawFilled(enabled: boolean): void;

  getGradientFillColor(): JArrayList<ChartColorStop> | null;

  setGradientFillColor(linearGradientColors: JArrayList<ChartColorStop>): void;
}
