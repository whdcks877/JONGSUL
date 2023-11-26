import asyncio
import cv2
import numpy as np
import websockets
import base64
import json

async def receive_results(uri):
    async with websockets.connect(uri) as websocket:
        cnt = 0
        while True:
            # Receive the base64-encoded image data
            combined_data_str = await websocket.recv()
            cnt += 1
            combined_data = json.loads(combined_data_str)
            image_data = combined_data["image_data"]
            boxes = json.loads(combined_data["results_json"])

            # Decode the base64 data and convert it back to an image
            decoded_data = base64.b64decode(image_data)
            nparr = np.frombuffer(decoded_data, np.uint8)
            frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            # Draw YOLO results on the frame
            for box in boxes:
                point = np.squeeze(box["point"])
                score = np.squeeze(box["score"])
                class_name = np.squeeze(box["class"])

                # Draw bounding box on the frame
                x1 = int(point[0])
                y1 = int(point[1])
                x2 = int(point[2])
                y2 = int(point[3])

                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

                # Display class name and confidence score
                label = f"{class_name}: {score:.2f}"
                cv2.putText(frame, label, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

            # Display the frame
            cv2.imshow("YOLO Results", frame)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

asyncio.get_event_loop().run_until_complete(receive_results('ws://localhost:8765'))