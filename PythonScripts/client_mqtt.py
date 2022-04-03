# ====================================================================
# Implementacao do client MQTT utilizando a bilbioteca MQTT Paho
# ====================================================================
import paho.mqtt.client as mqtt
import time
from usuario import *

Lab_Broker = "labdigi.wiseful.com.br"     # Endereco do broker
Lab_Port = 80                             # Porta utilizada (firewall da USP exige 80)
KeepAlive = 60                            # Intervalo de timeout (60s)

Mos_Broker = "test.mosquitto.org"         # Endereco do broker do mosquitto
Mos_Port = 1883                           # Porta utilizada

db = 1                                    # Flag de depuracao (verbose)

ultimo_topico = ""

serial_val = ""
receving_serial = False
contador = 0
max_contador = 7

# Quando conectar na rede (Callback de conexao)
def lab_on_connect(client, userdata, flags, rc):
    print("Conectado com codigo " + str(rc))

    client.subscribe(user+"/V0", qos=0)
    client.subscribe(user+"/V1", qos=0)
    client.subscribe(user+"/FimJog", qos=0)
    client.subscribe(user+"/TX", qos=0)

# Quando conectar na rede (Callback de conexao)
def mos_on_connect(client, userdata, flags, rc):
    print("Conectado com codigo " + str(rc))

    client.subscribe(user+"/Init", qos=0)
    client.subscribe(user+"/Dif0", qos=0)
    client.subscribe(user+"/Dif1", qos=0)
    client.subscribe(user+"/B0", qos=0)
    client.subscribe(user+"/B1", qos=0)
    client.subscribe(user+"/B2", qos=0)
    client.subscribe(user+"/B3", qos=0)
    client.subscribe(user+"/B4", qos=0)
    client.subscribe(user+"/B5", qos=0)
    client.subscribe(user+"/Reset", qos=0)

# Quando receber uma mensagem (Callback de mensagem)
def lab_on_message(client, b, msg):
    if(msg.topic == user+"/TX"):
        global max_contador
        global serial_val
        global receving_serial
        global contador
        if(not (receving_serial) and msg.payload.decode("utf-8") == "0"):
            print("Iniciando do TX")
            receving_serial = True
            contador = 0
            serial_val = ""
        elif(not (receving_serial) and msg.payload.decode("utf-8") == "1"):
            print("Dummy...")
        else:
            print("Adicionando " + msg.payload.decode("utf-8"))
            serial_val = msg.payload.decode("utf-8") + serial_val
            if(contador == max_contador):
                print("Publicando msg final")
                Mos_client.publish(user+"/Serial", payload=serial_val, qos=0)
                receving_serial = False
            contador += 1
    else:
        client.newmsg = True
        print("msg from LabDigi: " + msg.payload.decode("utf-8"))
        client.msg = msg.payload.decode("utf-8")
        Mos_client.publish(msg.topic, payload=msg.payload.decode("utf-8"), qos=0)

# Quando receber uma mensagem (Callback de mensagem)
def mos_on_message(client, a, msg):
    client.newmsg = True
    print("msg from mosquitto: " + msg.payload.decode("utf-8"))
    client.msg = msg.payload.decode("utf-8")
    Lab_client.publish(msg.topic, payload=msg.payload.decode("utf-8"), qos=0)

Lab_client = mqtt.Client()                              # Criacao do cliente MQTT
Lab_client.on_connect = lab_on_connect                  # Vinculo do Callback de conexao
Lab_client.on_message = lab_on_message                  # Vinculo do Callback de mensagem recebida
Lab_client.username_pw_set(user, passwd)                # Apenas para coneccao com login/senha
Lab_client.connect(Lab_Broker, Lab_Port, KeepAlive)     # Conexao do cliente ao broker

Mos_client = mqtt.Client()                              # Criacao do cliente MQTT
Mos_client.on_connect = mos_on_connect                  # Vinculo do Callback de conexao
Mos_client.on_message = mos_on_message                  # Vinculo do Callback de mensagem recebida
Mos_client.username_pw_set(user, passwd)                # Apenas para coneccao com login/senha
Mos_client.connect(Mos_Broker, Mos_Port, KeepAlive)     # Conexao do cliente ao broker

while(True):
    Lab_client.loop_start()
    time.sleep(1)
    Lab_client.loop_stop()
    Mos_client.loop_start()
    time.sleep(1)
    Mos_client.loop_stop()


