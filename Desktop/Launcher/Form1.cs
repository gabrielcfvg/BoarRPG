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
        UdpClient client = null;
        private string ip = "127.0.0.1";
        private int port = 1234;

        public Form1()
        {
            InitializeComponent();
            client = new UdpClient(1222);
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

            byte[] protocoledData = Encoding.ASCII.GetBytes(data);
            client.Send(protocoledData, protocoledData.Length,"127.0.0.1",1234);
            awaitAnswer();
        }

        private void awaitAnswer()
        {
            IPEndPoint RemoteIpEndPoint = new IPEndPoint(IPAddress.Any, port);
            Byte[] receiveBytes = client.Receive(ref RemoteIpEndPoint);
            string answer = Encoding.ASCII.GetString(receiveBytes).Split(':')[1];
            lAnswer.Text = answer;
            if (answer[0] == '1')
            {
                this.Close();
            }
        }

    }
}
