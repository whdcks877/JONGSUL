from ultralytics import YOLO
import cv2
import websockets
import asyncio
import base64
import numpy as np
import json
from multiprocessing import Process, Queue
import functools


model = YOLO("yolov8s.pt")
esp32_address = "http://172.20.10.9:81/stream"


names = {0: 'person', 1: 'bicycle', 2: 'car', 3: 'motorcycle', 4: 'airplane', 5: 'bus', 6: 'train', 7: 'truck', 8: 'boat', 9: 'traffic light', 10: 'fire hydrant', 11: 'stop sign', 12: 'parking meter', 13: 'bench', 14: 'bird', 15: 'cat', 16: 'dog', 17: 'horse', 18: 'sheep', 19: 'cow', 20: 'elephant', 21: 'bear', 22: 'zebra', 23: 'giraffe', 24: 'backpack', 25: 'umbrella', 26: 'handbag', 27: 'tie', 28: 'suitcase', 29: 'frisbee', 30: 'skis', 31: 'snowboard', 32: 'sports ball', 33: 'kite', 34: 'baseball bat', 35: 'baseball glove', 36: 'skateboard', 37: 'surfboard', 38: 'tennis racket', 39: 'bottle', 40: 'wine glass', 41: 'cup', 42: 'fork', 43: 'knife', 44: 'spoon', 45: 'bowl', 46: 'banana', 47: 'apple', 48: 'sandwich', 49: 'orange', 50: 'broccoli', 51: 'carrot', 52: 'hot dog', 53: 'pizza', 54: 'donut', 55: 'cake', 56: 'chair', 57: 'couch', 58: 'potted plant', 59: 'bed', 60: 'dining table', 61: 'toilet', 62: 'tv', 63: 'laptop', 64: 'mouse', 65: 'remote', 66: 'keyboard', 67: 'cell phone', 68: 'microwave', 69: 'oven', 70: 'toaster', 71: 'sink', 72: 'refrigerator', 73: 'book', 74: 'clock', 75: 'vase', 76: 'scissors', 77: 'teddy bear', 78: 'hair drier', 79: 'toothbrush'}




async def send_results(websocket, path, frame_q:Queue, box_q:Queue):
    global names
    global esp32_address


    cap = cv2.VideoCapture(esp32_address)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT , float(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)))
    cap.set(cv2.CAP_PROP_FRAME_WIDTH , float(cap.get(cv2.CAP_PROP_FRAME_WIDTH)))


    cnt = 0
    old_json = ""
    while cap.isOpened():
        ret, frame = cap.read()

        if ret:
            if(old_json == ""):
                frame_q.put(frame)
                while True:
                    if(not box_q.empty()):
                        old_json = box_q.get()
                        break

            if(not box_q.empty()):
                old_json = box_q.get()

            # Convert the image to base64 for transmission
            _, buffer = cv2.imencode('.jpg', frame)
            image_data = base64.b64encode(buffer).decode('utf-8')


            combined_data = {
                "image_data": image_data,
                "results_json" : old_json
            }

            # Sending the YOLO results and image
            await websocket.send(json.dumps(combined_data))

            cnt += 1
            if(cnt == 20):
                frame_q.put(frame)
                cnt = 0
        else:
            cap.release()
            cap = cv2.VideoCapture(esp32_address)
            while not cap.isOpened():
                pass

        if cv2.waitKey(5) & 0xFF == ord('q'):
            break


    cv2.destroyAllWindows()
    cap.release()




def p_frame(frame_q:Queue, box_q:Queue):
    # Create an event loop
    loop = asyncio.get_event_loop()

    # Start the WebSocket server
    start_server = websockets.serve(functools.partial(send_results, frame_q=frame_q, box_q=box_q), "localhost", 8765)
    
    # Run the event loop until the server is closed
    loop.run_until_complete(start_server)
    print("Server is Running")
    loop.run_forever()

def p_yolo(frame_q:Queue, box_q:Queue):
    while True:
        if(not frame_q.empty()):
            frame = frame_q.get()
            results = model(frame)
            boxes = results[0].boxes


            json_data_list = []
            for box in boxes:
                json_data = {
                    "point": box.xyxy.cpu().detach().numpy().tolist(),
                    "score": box.conf.cpu().detach().numpy().tolist(),
                    "class": names[box.cls.cpu().detach().numpy().tolist()[0]]
                }
                json_data_list.append(json_data)

            # Convert the list of dictionaries to a JSON string
            json_string = json.dumps(json_data_list)
            box_q.put(json_string)

if __name__ == "__main__":
    frame_q = Queue()
    box_q = Queue()
    
    ps = Process(target=p_frame, args=(frame_q,box_q,))
    pg = Process(target=p_yolo, args=(frame_q,box_q,))
#    ch = Process(target=check_q, args=(data_q,))

    pg.start()
    ps.start()
#    ch.start()


    ps.join()
    pg.join()