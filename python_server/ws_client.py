import asyncio
# 웹 소켓 모듈을 선언한다.
import websockets
import keyboard

# ----------------------------------------------------------------------------------------------//
# Python 웹소켓 서버에 접속에서 프롬프트 상에서 문자열을 입력받아 Python 웹소켓 서버에 전송하고
# 전송한 문자열에 대한 에코를 리턴 받는다.
# quit(종료) 문자를 입력받을 때까지 계속 웹소켓 연결되어 있다. quit 문자가 입력되면 접속이 자동으로 끊긴다.
# Python 웹소켓 서버는 파이참에서 실행중이다.
# ----------------------------------------------------------------------------------------------//


async def connect():

    # 웹 소켓에 접속을 합니다.
    async with websockets.connect("ws://localhost:9997/") as websocket:

        str = input('Python 웹소켓으로 전송할 내용을 입력하세요[종료하려면 quit 입력!]: ')     # 사용자의 입력을 변수에 저장
        #print(str)  # 변수의 내용을 출력

        #입력받은 값을 파일로 저장

        while str != 'quit':
            str = ""
            # quit가 들어오기 전까지 계속 입력받은 문자열을 전송하고 에코를 수신한다.
            key = keyboard.read_key()
            if key == "w":
                str = "UP"
                if(keyboard.is_pressed('w')):
                    str = "UP"
                else:
                    str = "STOP"

            elif key == "a":
                str = "LEFT"
                if(keyboard.is_pressed('a')):
                    str = "LEFT"
                else:
                    str = "STOP"
                    
            elif key == "d":
                str = "RIGHT"
                if(keyboard.is_pressed('d')):
                    str = "RIGHT"
                else:
                    str = "STOP"

            elif key == "s":
                str = "DOWN"
                if(keyboard.is_pressed('s')):
                    str = "DOWN"
                else:
                    str = "STOP"

            await websocket.send(str);

            # 웹 소켓 서버로 부터 메시지가 오면 콘솔에 출력합니다.
            data = await websocket.recv();


# 비동기로 서버에 접속한다.
asyncio.get_event_loop().run_until_complete(connect())