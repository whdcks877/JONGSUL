import asyncio
import websockets
from multiprocessing import Process, Queue
import functools
import time


#Get data from App
async def get_ctrl(websocket, path, _queue:Queue):
    while True:
        # 클라이언트로부터 메시지를 대기한다.
        data = await websocket.recv()
        print("receive : " + data)
        _queue.put(data)

        # 클라인언트로 echo를 붙여서 재 전송한다
        await websocket.send("echo : " + data)

#Send data to ESP32
async def send_ctrl(_queue:Queue):
    async with websockets.connect("ws://172.20.10.10:81/") as websocket:
        while True:
            if (not _queue.empty()):
                data = _queue.get()
                await websocket.send(data)
                print("send : " + data)

                # 웹 소켓 서버로 부터 메시지가 오면 콘솔에 출력합니다.
                data = await websocket.recv()

def p_get_ctrl(_queue:Queue):
    start_server = websockets.serve(functools.partial(get_ctrl,_queue=_queue), "localhost", 9997)

    # 비동기로 서버를 대기한다.
    asyncio.get_event_loop().run_until_complete(start_server)
    asyncio.get_event_loop().run_forever()

def p_send_ctrl(_queue:Queue):
    # 비동기로 서버에 접속한다.
    asyncio.get_event_loop().run_until_complete(send_ctrl(_queue))
    asyncio.get_event_loop().run_forever()

def check_q(_queue:Queue):
    while True:
        print(_queue.empty())
        time.sleep(1)
    

if __name__ == "__main__":
    data_q = Queue()

    ps = Process(target=p_send_ctrl, args=(data_q,))
    pg = Process(target=p_get_ctrl, args=(data_q,))
#    ch = Process(target=check_q, args=(data_q,))

    pg.start()
    ps.start()
#    ch.start()


    ps.join()
    pg.join()