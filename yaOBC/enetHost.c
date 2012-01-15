/*
 * This program was formed basically by just cutting and pasting
 * from the enet tutorial (http://enet.bespin.org/Tutorial.html)
 * and then adding a thread for keyboard input, so I guess it should
 * have the same license as the tutorial has ... which isn't specified.
 * The enet library itself has the following license, so let's suppose
 * that it's the license that applies:
 *
 *      Copyright (c) 2002-2011 Lee Salzman
 *
 *      Permission is hereby granted, free of charge, to any person
 *      obtaining a copy of this software and associated documentation
 *      files (the "Software"), to deal in the Software without
 *      restriction, including without limitation the rights to use,
 *      copy, modify, merge, publish, distribute, sublicense, and/or
 *      sell copies of the Software, and to permit persons to whom
 *      the Software is furnished to do so, subject to the following
 *      conditions:
 *
 *      The above copyright notice and this permission notice shall be
 *      included in all copies or substantial portions of the Software.
 *
 *      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *      EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 *      OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *      NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 *      HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 *      WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *      FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *      OTHER DEALINGS IN THE SOFTWARE.
 *
 * Filename:    enetHostTest.c
 * Purpose:     Provides a test for the socket interface used to
 *              connect Gemini OBC emulation programs like yaOBC,
 *              yaPanel, etc.  It can act either as a client (for
 *              connecting to yaOBC) or a server (for connecting
 *              to yaPanel et al.).  Once running, it simply sends
 *              any strings typed at the keyboard to the server
 *              (if it's a client) or to all connected clients
 *              (if it's a server).  Conversely, it prints any
 *              strings it receives from connected sockets.
 * Reference:   http://www.ibiblio.org/apollo/Gemini.html#Protocol
 * History:     2012-01-14 RSB  Wrote.
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <enet/enet.h>

#define PORT 19653
#define PROMPT "enet> "
static int Port = PORT;

// Should really protect the variable "peer" with a mutex,
// since in theory there would be a brief interval after a
// disconnect in which the variable might still be non-NULL
// even though the disconnect had already occurred, and
// therefore KeyboardThreadFunction() might be tricked into
// using it, possibly crashing the program.
static volatile ENetPeer *peer = NULL;
static int IsServer = 0; // 1 for server, 0 for client.
static ENetHost *host;

// Function for the keyboard thread.
void *
KeyboardThreadFunction(void *Data)
{
  int i;
  char Input[81] = "hello", *s;
  ENetPacket *packet;

  fprintf(stderr, "Ctrl-C to exit.\n");
  while (1)
    {
      fprintf(stderr, PROMPT);
      if (NULL == fgets(Input, sizeof(Input), stdin))
        continue;
      if (!IsServer && peer == NULL)
        {
          fprintf(stderr, "Not connected to server.\n");
          continue;
        }
      // Trim off trailing CR or LF.
      for (s = Input; *s; s++)
        if (*s == '\n' || *s == '\r')
          {
            *s = 0;
            break;
          }
      packet = enet_packet_create(Input, strlen(Input) + 1,
          ENET_PACKET_FLAG_RELIABLE);
      if (IsServer)
        enet_host_broadcast(host, 0, packet);
      else
        {
          i = enet_peer_send((ENetPeer *) peer, 0, packet);
          if (i)
            fprintf(stderr, "Failed.\n");
          else
            fprintf(stderr, "Succeeded.\n");
        }
      enet_host_flush(host);
    }
}

int
main(int argc, char **argv)
{
  int i, j, RetVal = 1;
  pthread_t KeyboardThread;

  // Parse the command-line arguments.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp(argv[i], "--client"))
        IsServer = 0;
      else if (!strcmp(argv[i], "--server"))
        IsServer = 1;
      else if (1 == sscanf (argv[i], "--port=%d", &j))
        Port = j;
      else
        {
          fprintf(stderr, "USAGE:\n");
          fprintf(stderr, "     enetHostTest [OPTIONS]\n");
          fprintf(stderr, "The allowed OPTIONS are:\n");
          fprintf(stderr, "--help    Display this help-info.\n");
          fprintf(stderr, "--server  Start a server.\n");
          fprintf(stderr, "--client  Start a client (the default).\n");
          fprintf(stderr, "--port=P  Defaults to --port=%d.\n", PORT);
          return (1);
        }
    }

  // Initialize the socket library.
  if (enet_initialize() != 0)
    {
      fprintf(stderr, "An error occurred while initializing ENet.\n");
      return EXIT_FAILURE;
    }
  atexit(enet_deinitialize);

  //---------------------------------------------------------------------------
  // Set up the host as either a client or a server.  In either
  // case, the variable "host" will be used as a pointer to the host.
  if (IsServer)
    {
      ENetAddress address;
      ENetHost *server;

      fprintf(stderr, "Starting up enet server.\n");

      /* Bind the server to the default localhost.     */
      /* A specific host address can be specified by   */
      /* enet_address_set_host (& address, "x.x.x.x"); */

      address.host = ENET_HOST_ANY;
      /* Bind the server to port. */
      address.port = Port;

      server = enet_host_create(&address, 32, 1, 0, 0);
      if (server == NULL)
        {
          fprintf(stderr,
              "An error occurred while trying to create an ENet server host.\n");
          exit(EXIT_FAILURE);
        }
      host = server;
    }
  else // !IsServer, so must be a client.
    {
      ENetHost *client;

      fprintf(stderr, "Starting up enet client.\n");

      client = enet_host_create(NULL, 1, 2, 0, 0);

      if (client == NULL)
        {
          fprintf(stderr,
              "An error occurred while trying to create an ENet client host.\n");
          exit(EXIT_FAILURE);
        }
      host = client;

    }

  //---------------------------------------------------------------------------
  // Start up another thread to get keyboard commands, so as to be able to 
  // initiate messages over the socket connection.  
  i = pthread_create(&KeyboardThread, NULL, KeyboardThreadFunction, NULL);
  if (i != 0)
    {
      fprintf(stderr, "Keyboard thread creation failed with code %d.\n", i);
      goto Done;
    }

  //---------------------------------------------------------------------------
  // Infinite loop to service the host.
  while (1)
    {
      ENetEvent event;
      ENetAddress address;

      // Connect to the server, if necessary.
      if (!IsServer && peer == NULL)
        {
          enet_address_set_host(&address, "localhost");
          address.port = Port;
          peer = enet_host_connect(host, &address, 2, 0);
          if (peer == NULL)
            {
              fprintf(stderr, "\rConnection failed.\n" PROMPT);
#ifdef WIN32
              Sleep (100);
#else
              usleep(100 * 1000);
#endif
            }
        }

      // Service the host for incoming packets, connects, disconnects.
      enet_host_service(host, &event, 1000);
      switch (event.type)
        {
      case ENET_EVENT_TYPE_CONNECT:
        fprintf(stderr, "\rA new client connected from 0x%08X:%u.\n" PROMPT,
            event.peer -> address.host, event.peer -> address.port);

        /* Store any relevant client information here. */
        event.peer -> data = "Client information";

        break;

      case ENET_EVENT_TYPE_RECEIVE:
        fprintf (stderr, "\r");
        printf(
            "%u 0x%08X:%u \"%s\"\n",
            event.packet -> dataLength,
            event.peer -> address.host, event.peer -> address.port,
            event.packet -> data);
        fflush(stdout);
        fprintf (stderr, PROMPT);

        /* Clean up the packet now that we're done using it. */
        enet_packet_destroy(event.packet);

        break;

      case ENET_EVENT_TYPE_DISCONNECT:
        fprintf(stderr, "\r0x%08X:%u disconnected.\n" PROMPT,
            event.peer -> address.host, event.peer -> address.port);

        /* Reset the peer's client information. */

        event.peer -> data = NULL;
        if (!IsServer)
          peer = NULL;

        break;

      default:
        //printf ("No events.\n");
        break;
        }
    }

  RetVal = 0;
  Done: ;
  enet_host_destroy(host);
  return (RetVal);
}
