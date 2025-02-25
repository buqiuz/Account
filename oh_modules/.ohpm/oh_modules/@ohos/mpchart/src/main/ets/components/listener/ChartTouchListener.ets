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

import Highlight from '../highlight/Highlight';
import Chart from '../charts/ChartModel';
import OnChartGestureListener from './OnChartGestureListener';
import EntryOhos from '../data/EntryOhos';
import IDataSet from '../interfaces/datasets/IDataSet';
import ChartData from '../data/ChartData';
import Utils from '../utils/Utils';

export enum ChartGesture {
  NONE, DRAG, X_ZOOM, Y_ZOOM, PINCH_ZOOM, ROTATE, SINGLE_TAP, DOUBLE_TAP, LONG_PRESS, FLING
}

/**
 * Created by philipp on 12/06/15.
 */

export default abstract class ChartTouchListener<T extends Chart<ChartData<IDataSet<EntryOhos>>>> {
  /**
   * the last touch gesture that has been performed
   **/
  public mLastGesture: ChartGesture = ChartGesture.NONE;
  // states
  protected static NONE: number = 0;
  protected static DRAG: number = 1;
  protected static X_ZOOM: number = 2;
  protected static Y_ZOOM: number = 3;
  protected static PINCH_ZOOM: number = 4;
  protected static POST_ZOOM: number = 5;
  protected static ROTATE: number = 6;
  protected static LONG_PRESS: number = 7;
  /**
   * integer field that holds the current touch-state
   */
  protected mTouchMode: number = ChartTouchListener.NONE;
  /**
   * the last highlighted object (via touch)
   */
  protected mLastHighlighted: Highlight | null = null;
  /**
   * the gesturedetector used for detecting taps and longpresses, ...
   */
  //    protected mGestureDetector:GestureDetector;

  /**
   * the chart the listener represents
   */
  protected mChart: T;

  constructor(chart: T) {
    this.mChart = chart;

    //        mGestureDetector = new GestureDetector(chart.getContext(), this);
  }

  /**
   * Calls the OnChartGestureListener to do the start callback
   *
   * @param me
   */
  public startAction(isTouchEvent: boolean, me: TouchEvent | GestureEvent) {

    let l: OnChartGestureListener | null = this.mChart.getOnChartGestureListener();

    if (l != null) {
      l.onChartGestureStart(isTouchEvent, me, this.mLastGesture);
    }
  }

  /**
   * Calls the OnChartGestureListener to do the end callback
   *
   * @param me
   */
  public endAction(isTouchEvent: boolean, me: TouchEvent | GestureEvent) {

    let l: OnChartGestureListener | null = this.mChart.getOnChartGestureListener();

    if (l != null) {
      l.onChartGestureEnd(isTouchEvent, me, this.mLastGesture);
    }
  }

  /**
   * Sets the last value that was highlighted via touch.
   *
   * @param high
   */
  public setLastHighlighted(high?: Highlight) {
    this.mLastHighlighted = high ? high : null;
  }

  /**
   * returns the touch mode the listener is currently in
   *
   * @return
   */
  public getTouchMode(): number {
    return this.mTouchMode;
  }

  /**
   * Returns the last gesture that has been performed on the chart.
   *
   * @return
   */
  public getLastGesture(): ChartGesture {
    return this.mLastGesture;
  }


  /**
   * Perform a highlight operation.
   *
   * @param e
   */
  protected performHighlight(h: Highlight, e?: TouchEvent) {

    if (h == null || Utils.isHighLightEquals(h, this.mLastHighlighted)) {
      // this.mChart.highlightValue(0,undefined,undefined, undefined,true);
      this.mChart.highlightValueForObject(null, true);
      this.mLastHighlighted = null;
    } else {
      this.mChart.highlightValueForObject(h, true);
      this.mLastHighlighted = h;
    }
  }

  /**
   * returns the distance between two points
   *
   * @param eventX
   * @param startX
   * @param eventY
   * @param startY
   * @return
   */
  protected static distance(eventX: number, startX: number, eventY: number, startY: number): number {
    let dx: number = eventX - startX;
    let dy: number = eventY - startY;
    return Math.sqrt(dx * dx + dy * dy);
  }

  abstract onTouch(event: TouchEvent): void;

  abstract onSingleTapUp(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract onDoubleTap(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract onLongPressed(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract onLongPressUp(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract onLongPressCancel(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract actionDown(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract actionMove(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract actionUp(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract actionCancel(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract actionPinchDown(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;

  abstract actionPinchUp(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void;
}
