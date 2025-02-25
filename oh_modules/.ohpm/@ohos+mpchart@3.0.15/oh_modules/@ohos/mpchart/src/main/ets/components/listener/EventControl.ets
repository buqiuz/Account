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

export const enum EventType {
  SingleTap,
  DoubleTap,
  LongPress
}

export class EventControl {
  private eventMap = new Map<EventType, boolean>();

  constructor() {
    this.eventMap
      .set(EventType.SingleTap, true)
      .set(EventType.DoubleTap, true)
      .set(EventType.LongPress, true);
  }

  // 事件是否启用
  public eventIsEnable(evType: EventType) {
    return this.eventMap.get(evType);
  }

  // 事件是否禁用
  public eventIsDisable(evType: EventType) {
    return !this.eventMap.get(evType);
  }

  // 启用所有事件
  public setAllEventEnable() {
    this.eventMap.forEach((val, key, m) => {
      m.set(key, true);
    })
    return this;
  }
  // 禁用所有事件
  public setAllEventDisable() {
    this.eventMap.forEach((val, key, m) => {
      m.set(key, false);
    })
    return this;
  }

  // 根据事件类型启用事件
  public setEventEnable(evType: EventType) {
    this.setEvent(evType, true);
    return this;
  }

  // 根据事件类型禁用事件
  public setEventDisable(evType: EventType) {
    this.setEvent(evType, false);
    return this;
  }

  private setEvent(evType: EventType, sel: boolean) {
    if (this.eventMap.has(evType)) {
      this.eventMap.set(evType, sel);
    }
  }
}