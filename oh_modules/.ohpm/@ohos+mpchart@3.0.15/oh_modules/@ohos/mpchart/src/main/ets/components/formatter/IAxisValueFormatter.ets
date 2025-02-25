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

import AxisBase from '../components/AxisBase';

/**
 * Custom formatter interface that allows formatting of
 * axis labels before they are being drawn.
 */
export default interface IAxisValueFormatter {

  /**
   * Called when a value from an axis is to be formatted
   * before being drawn. For performance reasons, avoid excessive calculations
   * and memory allocations inside this method.
   *
   * @param value the value to be formatted
   * @param axis  the axis the value belongs to
   * @return
   */
  getFormattedValue(value: number, axis: AxisBase): string;
}
