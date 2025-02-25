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

import PieRadarChartBase from '../charts/PieRadarChartBaseModel';
import ChartData from '../data/ChartData';
import EntryOhos from '../data/EntryOhos';
import Highlight from '../highlight/Highlight';
import IDataSet from '../interfaces/datasets/IDataSet';
import { JArrayList } from '../utils/JArrayList';
import MPPointF from '../utils/MPPointF';
import Utils from '../utils/Utils';
import ChartTouchListener, { ChartGesture } from './ChartTouchListener';
import OnChartGestureListener from './OnChartGestureListener';
import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator';

export default class PieRadarChartTouchListener extends ChartTouchListener<PieRadarChartBase<ChartData<IDataSet<EntryOhos>>>> {
  private mTouchStartPoint: MPPointF = MPPointF.getInstance(0, 0);
  /**
   * the angle where the dragging started
   */
  private mStartAngle: number = 0;
  private _velocitySamples: JArrayList<AngularVelocitySample> = new JArrayList<AngularVelocitySample>();
  private mDecelerationLastTime: number = 0;
  private mDecelerationAngularVelocity: number = 0;
  private animatorIsPlaying: boolean = false
  private animatorResult: AnimatorResult | null = null
  private prevAngle: number = 0


  constructor(chart: PieRadarChartBase<ChartData<IDataSet<EntryOhos>>>) {
    super(chart);
  }

  onTouch(event: TouchEvent) {

  }

  onSingleTapUp(isTouchEvent: boolean, e: TouchEvent | GestureEvent) {
    if (!e) {
      return;
    }
    this.actionDown(isTouchEvent, e);
    this.mLastGesture = ChartGesture.SINGLE_TAP;

    let l: OnChartGestureListener | null = this.mChart.getOnChartGestureListener();

    if (l != null) {
      l.onChartSingleTapped(isTouchEvent, e);
    }

    if (!this.mChart.isHighlightPerTapEnabled()) {
      return;
    }
    let x: number = 0;
    let y: number = 0;
    if (isTouchEvent) {
      let touch = e as TouchEvent;
      if (!touch.touches || touch.touches.length == 0 || !touch.touches[0]) {
        return;
      }
      x = touch.touches[0].x;
      y = touch.touches[0].y;
    } else {
      let gesture = e as GestureEvent;
      if (!gesture.fingerList || gesture.fingerList.length == 0 || !gesture.fingerList[0]) {
        return;
      }
      x = gesture.fingerList[0].localX;
      y = gesture.fingerList[0].localY;
    }
    let h: Highlight | null = this.mChart.getHighlightByTouchPoint(x, y);
    if (h) {
      this.performHighlight(h);
    }

    this.actionUp(isTouchEvent, e);

  }

  onLongPressed(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    // throw new Error('Method not implemented.');
  }

  onLongPressUp(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    // throw new Error('Method not implemented.');
  }

  onLongPressCancel(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    // throw new Error('Method not implemented.');
  }


  onDoubleTap(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    // throw new Error('Method not implemented.');
  }

  actionDown(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    if (!event || !this.mChart.isRotationEnabled()) {
      return;
    }
    let xCoordinate: number = 0;
    let yCoordinate: number = 0;
    if (isTouchEvent) {
      if (!!this.animatorResult && this.animatorIsPlaying) {
        this.animatorResult.pause();
        this.animatorIsPlaying = false;
      }
      event = event as TouchEvent;
      if (!event.touches || event.touches.length == 0 || !event.touches[0]) {
        return;
      }
      xCoordinate = event.touches[0].x;
      yCoordinate = event.touches[0].y;
    } else {
      event = event as GestureEvent;
      if (!event.fingerList || event.fingerList.length == 0 || !event.fingerList[0]) {
        return;
      }
      xCoordinate = event.fingerList[0].localX;
      yCoordinate = event.fingerList[0].localY;
    }


    this.startAction(isTouchEvent, event);

    this.stopDeceleration();

    this.resetVelocity();

    if (this.mChart.isDragDecelerationEnabled()) {
      this.sampleVelocity(xCoordinate, yCoordinate);
    }

    this.setGestureStartAngle(xCoordinate, yCoordinate);
    this.mTouchStartPoint.x = xCoordinate;
    this.mTouchStartPoint.y = yCoordinate;

    this.prevAngle = this.calculateAngle(xCoordinate, yCoordinate)

  }

  actionMove(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    if (!event || !this.mChart.isRotationEnabled()) {
      return;
    }
    let xCoordinate: number = 0;
    let yCoordinate: number = 0;
    if (isTouchEvent) {
      event = event as TouchEvent;
      if (!event.touches || event.touches.length == 0 || !event.touches[0]) {
        return;
      }
      xCoordinate = event.touches[0].x;
      yCoordinate = event.touches[0].y;
    } else {
      event = event as GestureEvent;
      if (!event.fingerList || event.fingerList.length == 0 || !event.fingerList[0]) {
        return;
      }
      xCoordinate = event.fingerList[0].localX;
      yCoordinate = event.fingerList[0].localY;
    }
    if (this.mChart.isDragDecelerationEnabled()) {
      this.sampleVelocity(xCoordinate, yCoordinate);
    }

    if (this.mTouchMode == ChartTouchListener.NONE
      && PieRadarChartTouchListener.distance(xCoordinate, this.mTouchStartPoint.x, yCoordinate, this.mTouchStartPoint.y)
        > Utils.handleDataValues(8)) {
      this.mLastGesture = ChartGesture.ROTATE;
      this.mTouchMode = ChartTouchListener.ROTATE;
      this.mChart.disableScroll();
    } else if (this.mTouchMode == ChartTouchListener.ROTATE) {
      this.updateGestureRotation(xCoordinate, yCoordinate);
      this.mChart.invalidate();
    }

    this.endAction(isTouchEvent, event);

  }

  actionUp(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    if (!event) {
      return;
    }
    let xCoordinate: number = 0;
    let yCoordinate: number = 0;
    if (isTouchEvent) {
      event = event as TouchEvent;
      if (!event.touches || event.touches.length == 0 || !event.touches[0]) {
        return;
      }
      xCoordinate = event.touches[0].x;
      yCoordinate = event.touches[0].y;
    } else {
      event = event as GestureEvent;
      if (!event.fingerList || event.fingerList.length == 0 || !event.fingerList[0]) {
        return;
      }
      xCoordinate = event.fingerList[0].localX;
      yCoordinate = event.fingerList[0].localY;
    }
    if (this.mChart.isDragDecelerationEnabled()) {

      this.stopDeceleration();

      this.sampleVelocity(xCoordinate, yCoordinate);

      this.mDecelerationAngularVelocity = this.calculateVelocity();

      if (this.mDecelerationAngularVelocity != 0.0) {
        this.mDecelerationLastTime = Date.now();

        this.mChart.invalidate();
      }
    }

    this.mChart.enableScroll();
    this.mTouchMode = ChartTouchListener.NONE;

    this.endAction(isTouchEvent, event);
  }

  actionCancel(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    this.mTouchMode = ChartTouchListener.NONE;
    this.endAction(isTouchEvent, event);
  }

  actionPinchDown(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    throw new Error('Method not implemented.');
  }

  actionPinchUp(isTouchEvent: boolean, event: TouchEvent | GestureEvent) {
    throw new Error('Method not implemented.');
  }

  public stopDeceleration() {
    this.mDecelerationAngularVelocity = 0.0;
  }

  private resetVelocity() {
    this._velocitySamples.clear();
  }

  private sampleVelocity(touchLocationX: number, touchLocationY: number): void {

    let currentTime: number = Date.now();

    this._velocitySamples.add(new AngularVelocitySample(currentTime,
      this.mChart.getAngleForPoint(touchLocationX, touchLocationY)));

    // Remove samples older than our sample time - 1 seconds
    for (let i = 0, count = this._velocitySamples.size(); i < count - 2; i++) {
      if (currentTime - this._velocitySamples.get(i).time > 1000) {
        this._velocitySamples.removeIndex(0);
        i--;
        count--;
      } else {
        break;
      }
    }
  }

  public setGestureStartAngle(x: number, y: number): void {
    this.mStartAngle = this.mChart.getAngleForPoint(x, y) - this.mChart.getRawRotationAngle();
  }

  public updateGestureRotation(x: number, y: number): void {
    this.mChart.setRotationAngle(this.mChart.getAngleForPoint(x, y) - this.mStartAngle);
  }

  public computeScroll(event: GestureEvent): void {
    let xCoordinate = event.fingerList[0].localX;
    let yCoordinate = event.fingerList[0].localY;
    let currentAngle = this.mChart.getRotationAngle();
    let angleDiff = this.calculateAngle(xCoordinate, yCoordinate) - this.prevAngle;
    if (angleDiff < -180) {
      angleDiff += 360;
    }
    if (angleDiff > 180) {
      angleDiff -= 360;
    }
    let end = angleDiff > 0 ? currentAngle + (event.speed / 30) : currentAngle - (event.speed / 30);
    let options: AnimatorOptions = {
      duration: 1000,
      easing: "ease-out",
      delay: 0,
      fill: "forwards",
      direction: "normal",
      begin: currentAngle,
      end: end,
      iterations: 1
    };
    if (!!this.animatorResult) {
      this.animatorIsPlaying = false;
      this.animatorResult.reset(options);
    } else {
      this.animatorResult = animator.create(options)
    }
    this.animatorResult.onframe = (value) => {
      this.mChart.setRotationAngle(value);
      this.mChart.invalidate();
    }

    this.animatorResult.onfinish = () => {
      this.animatorIsPlaying = false;
    }

    this.animatorResult.play();
    this.animatorIsPlaying = true;
  }

  private calculateAngle(x: number, y: number): number {
    // 计算触摸点相对于圆心的角度（0-360度）
    let angleRadians = Math.atan2(y - this.mChart.getHeight() / 2, x - this.mChart.getWidth() / 2);
    let angleDegrees = angleRadians * (180 / Math.PI);
    if (angleDegrees < 0) {
      angleDegrees += 360; // 将负角度转换为0-360度范围
    }
    return angleDegrees;
  }

  private calculateVelocity(): number {

    if (this._velocitySamples.isEmpty()) {
      return 0.0;
    }

    let firstSample: AngularVelocitySample = this._velocitySamples.get(0);
    let lastSample: AngularVelocitySample = this._velocitySamples.get(this._velocitySamples.size() - 1);

    // Look for a sample that's closest to the latest sample, but not the same, so we can deduce the direction
    let beforeLastSample: AngularVelocitySample = firstSample;
    for (let i = this._velocitySamples.size() - 1; i >= 0; i--) {
      beforeLastSample = this._velocitySamples.get(i);
      if (beforeLastSample.angle != lastSample.angle) {
        break;
      }
    }

    // Calculate the sampling time
    let timeDelta: number = (lastSample.time - firstSample.time) / 1000.0;
    if (timeDelta == 0.0) {
      timeDelta = 0.1;
    }

    // Calculate clockwise/ccw by choosing two values that should be closest to each other,
    // so if the angles are two far from each other we know they are inverted "for sure"
    let clockwise: boolean = lastSample.angle >= beforeLastSample.angle;
    if (Math.abs(lastSample.angle - beforeLastSample.angle) > 270.0) {
      clockwise = !clockwise;
    }

    // Now if the "gesture" is over a too big of an angle - then we know the angles are inverted, and we need to move them closer to each other from both sides of the 360.0 wrapping point
    if (lastSample.angle - firstSample.angle > 180.0) {
      firstSample.angle += 360.0;
    } else if (firstSample.angle - lastSample.angle > 180.0) {
      lastSample.angle += 360.0;
    }

    // The velocity
    let velocity: number = Math.abs((lastSample.angle - firstSample.angle) / timeDelta);

    // Direction?
    if (!clockwise) {
      velocity = -velocity;
    }

    return velocity;
  }
}

class AngularVelocitySample {
  public time: number = 0;
  public angle: number = 0;

  constructor(time: number, angle: number) {
    this.time = time;
    this.angle = angle;
  }
}