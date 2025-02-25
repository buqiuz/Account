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

import { ChartGesture } from './ChartTouchListener';

/**
 * Listener for callbacks when doing gestures on the chart.
 *
 *
 */
export default interface OnChartGestureListener {

  /**
   * Callbacks when a touch-gesture has started on the chart (ACTION_DOWN)
   *
   * @param me
   * @param lastPerformedGesture
   */
  onChartGestureStart: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, lastPerformedGesture: ChartGesture) => void;

  /**
   * Callbacks when a touch-gesture has ended on the chart (ACTION_UP, ACTION_CANCEL)
   *
   * @param me
   * @param lastPerformedGesture
   */
  onChartGestureEnd: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, lastPerformedGesture: ChartGesture) => void;

  /**
   * Callbacks when the chart is longpressed.
   *
   * @param me
   */
  onChartLongPressed: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => void;

  /**
   * Callbacks when the chart is double-tapped.
   *
   * @param me
   */
  onChartDoubleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => void;

  /**
   * Callbacks when the chart is single-tapped.
   *
   * @param me
   */
  onChartSingleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => void;

  /**
   * Callbacks then a fling gesture is made on the chart.
   *
   * @param me1
   * @param me2
   * @param velocityX
   * @param velocityY
   */
  onChartFling: (isTouchEvent: boolean, me1: TouchEvent | GestureEvent, me2: TouchEvent, velocityX: number, velocityY: number) => void;

  /**
   * Callbacks when the chart is scaled / zoomed via pinch zoom / double-tap gesture.
   *
   * @param me
   * @param scaleX scalefactor on the x-axis
   * @param scaleY scalefactor on the y-axis
   */
  onChartScale: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, scaleX: number, scaleY: number) => void;

  /**
   * Callbacks when the chart is moved / translated via drag gesture.
   *
   * @param me
   * @param dX translation distance on the x-axis
   * @param dY translation distance on the y-axis
   */
  onChartTranslate: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, dX: number, dY: number) => void;

  /**
   * Callbacks when the finger is move.
   * @param isTouchEvent
   * @param me
   */
  onChartMove: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => void;
}
