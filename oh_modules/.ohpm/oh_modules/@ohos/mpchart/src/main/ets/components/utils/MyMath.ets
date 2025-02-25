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

export default class MyMath {
  /**
   * Constant by which to multiply an angular value in radians to obtain an
   * angular value in degrees.
   */
  private static radians: number = 57.29577951308232;
  /**
   * Constant by which to multiply an angular value in degrees to obtain an
   * angular value in radians.
   */
  private static degrees: number = 0.017453292519943295;

  /**
   * Converts an angle measured in degrees to an approximately
   * equivalent angle measured in radians.  The conversion from
   * degrees to radians is generally inexact.
   *
   * @param angdeg   an angle, in degrees
   * @return the measurement of the angle {@code angdeg}
   *          in radians.
   */
  public static toRadians(ang: number): number {
    return ang * MyMath.degrees;
  }


  /*
  Converts an angle measured in radians to an approximately equivalent angle measured in degrees. The conversion from radians to degrees is generally inexact; users should not expect cos(toRadians(90.0)) to exactly equal 0.0.
  Params:
  angrad – an angle, in radians
  */
  public static toDegrees(ang: number) {
    return ang * MyMath.radians
  }
}