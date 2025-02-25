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

import LineDataProvider from '../interfaces/dataprovider/LineDataProvider';
import ILineDataSet from '../interfaces/datasets/ILineDataSet';

/**
 * Interface for providing a custom logic to where the filling line of a LineDataSet
 * should end. This of course only works if setFillEnabled(...) is set to true.
 *
 *
 */
export default interface IFillFormatter {

  /**
   * Returns the vertical (y-axis) position where the filled-line of the
   * LineDataSet should end.
   *
   * @param dataSet the ILineDataSet that is currently drawn
   * @param dataProvider
   * @return
   */
  getFillLinePosition(dataSet: ILineDataSet, dataProvider: LineDataProvider): number;
}
