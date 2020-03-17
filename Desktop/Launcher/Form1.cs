using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Net;
using System.Net.Sockets;

namespace BOARMMO
{
    public partial class Form1 : Form
    {
        Socket client = null;
        private string ip = "127.0.0.1";
        private int port = 1234;

        public Form1()
        {
            InitializeComponent();
        }

        private void bLogin_Click(object sender, EventArgs e)
        {
            string user = textUser.Text;
            string pass = textPass.Text;
            string dt = protocolData(1, new String[] { user, pass, "login" });
            sendData(dt);

        }

        private void bRegister_Click(object sender, EventArgs e)
        {
            string user = textUser.Text;
            string pass = textPass.Text;
            string dt = protocolData(1,new String[] { user, pass,"register" });
            sendData(dt);
        }

        private string protocolData(int id,string[] values)
        {
            string output = id.ToString()+":";
            foreach (var item in values)
            {
                output += item;
                output += "|";
            }
            output = output.Remove(output.Length - 1);
            return output;
        }


        private void sendData(string data)
        {
            client = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            client.Connect(ip, port);
            byte[] protocoledData = Encoding.ASCII.GetBytes(data);
            client.Send(protocoledData);
            awaitAnswer();
        }

        private void awaitAnswer()
        {
            byte[] buffer = new byte[128];
            int size = client.Receive(buffer);
            client.Close();
            string  answerData = Encoding.ASCII.GetString(buffer);
            string answer = answerData.Split(':')[1];
            if (answer[0] == '1')
            {
                this.Close();
            }
        }


    }
}
