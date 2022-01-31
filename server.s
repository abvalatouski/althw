.globl _start
.text

   @ void _start(void);
   _start:
      @ sockfd = socket(AF_INET := 2, SOCK_STREAM := 1, 0);
      mov r0, #2
      mov r1, #1
      mov r2, #0
      bl socket
      mov r4, r0
      @ bind(sockfd, &server);
      ldr r1, =.server
      bl bind
      @ listen(sockfd, backlog := 5 /* I've read that GeekForGeeks article, too. (._.) */);
      mov r0, r4
      mov r1, #5
      bl listen
      @ while (true)
   .loop:
      @ connfd = accept(sockfd, &client);
      mov r0, r4
      bl accept
      @ write(connfd, response, sizeof(response));
      mov r7, #4
      ldr r1, =.response
      mov r2, #response_length
      swi #0
      b .loop
   .server:
      @ struct sockaddr_in server;
      @ server.sin_family = AF_INET := 2;
      @ server.sin_port = htons(80) := 0x5000;
      @ server.sin_addr.s_addr = inet_addr("127.0.0.1") := 0x0100007F;
      @ server.sin_zero = { 0 }; // padding
      .hword 2
      .hword 0x5000
      .word 0x0100007F
      .quad 0
   .client:
      .octa 0
   .response:
      .ascii "HTTP/1.1 200 OK\r\n"
      .ascii "Server: Poggers\r\n"
      .ascii "Connection: Closed\r\n"
      .ascii "Content-Type: text/html\r\n"
      .ascii "Content-Length: "
      .ascii "166" @ TODO: Calculate it automatically.
      .ascii "\r\n"
      .ascii "\r\n"
   .response_content:
      .ascii "<DOCTYPE html>\r\n"
      .ascii "<html>\r\n"
      .ascii "  <head>\r\n"
      .ascii "    <meta charset=\"utf-8\"/>\r\n"
      .ascii "    <title>Hello, world!</title>\r\n"
      .ascii "  </head>\r\n"
      .ascii "  <body>\r\n"
      .ascii "    <h1>Hello, world!</h1>\r\n"
      .ascii "  </body>\r\n"
      .ascii "</html>\r\n"
    response_content_length = . - .response_content
    response_length = . - .response

   @ static int32_t socket(int32_t domain, int32_t type, int32_t protocol);
   socket:
      push {r4, r5}
      @ if ((sockfd = /* syscall */ socket(domain, type, protocol)) == -1) goto socket_error;
      mov r7, #281
      swi #0
      cmn r0, #1
      beq .socket_error
      mov r5, r0
      @ if ((setsockopt(sockfd, SOL_SOCKET := 1, SO_REUSEADDR := 2, &true, sizeof(true))) == -1) goto setsockopt_error;
      mov r7, #294
      mov r1, #1
      mov r2, #2
      ldr r3, =.true
      mov r4, #4
      swi #0
      cmn r0, #1
      beq .setsockopt_error
      @ return sockfd;
      mov r0, r5
      pop {r4, r5}
      bx lr
   .socket_error:
      @ write(stderr := 2, socket_error_message, sizeof(socket_error_message));
      mov r7, #4
      mov r0, #2
      ldr r1, =.socket_error_message
      mov r2, #socket_error_message_length
      swi #0
      @ exit(1);
      mov r7, #1
      mov r0, #1
      swi #0
   .setsockopt_error:
      @ write(stderr := 2, setsockopt_error_message, sizeof(setsockopt_error_message));
      mov r7, #4
      mov r0, #2
      ldr r1, =.setsockopt_error_message
      mov r2, #setsockopt_error_message_length
      swi #0
      @ exit(1);
      mov r7, #1
      mov r0, #1
      swi #0
   .socket_error_message:
      .ascii "failed to create a socket:\nsocket returned -1"
   socket_error_message_length = . - .socket_error_message
   .setsockopt_error_message:
      .ascii "failed to create a socket:\nsetsockopt returned -1"
   setsockopt_error_message_length = . - .setsockopt_error_message
   .true:
      .word 1

      .space 2

   @ static int32_t bind(int32_t sockfd, int8_t addr[sizeof(struct sockaddr) := 16]);
   bind:
      @ if (/* syscall */ bind(sockfd, addr, sizeof(struct sockaddr) := 16) == -1) goto bind_error;
      mov r7, #282
      mov r2, #16
      swi #0
      cmn r0, #1
      beq .bind_error
      @ return;
      bx lr
   .bind_error:
      @ write(stderr := 2, bind_error_message, sizeof(bind_error_message));
      mov r7, #4
      mov r0, #2
      ldr r1, =.bind_error_message
      mov r2, #bind_error_message_length
      swi #0
      @ exit(1);
      mov r7, #1
      mov r0, #1
      swi #0
   .bind_error_message:
      .ascii "failed to bind the address:\nbind returned -1"
   bind_error_message_length = . - .bind_error_message

   @ static int32_t listen(int32_t sockfd, int32_t backlog);
   listen:
      @ if (/* syscall */ listen(sockfd, backlog) == -1) goto listen_error;
      mov r7, #284
      swi #0
      cmn r0, #1
      beq .listen_error
      @ return;
      bx lr
   .listen_error:
      @ write(stderr := 2, listen_error_message, sizeof(listen_error_message);
      mov r7, #4
      mov r0, #2
      ldr r1, =.listen_error_message
      mov r2, #listen_error_message_length
      swi #0
      @ exit(1);
      mov r7, #1
      mov r0, #1
      swi #0
   .listen_error_message:
      .ascii "failed to listen the connection:\nlisten returned -1"
   listen_error_message_length = . - .listen_error_message

      .space 1

   @ static int32_t accept(int32_t sockfd);
   accept:
      @ if ((connfd = /* syscall */ accept(sockfd, addr := NULL, socklen := NULL)) == -1) goto accept_error;
      mov r7, #285
      mov r1, #0
      mov r2, #0
      swi #0
      cmn r0, #1
      beq .accept_error
      @ return connfd;
      bx lr
   .accept_error:
      @ write(stderr := 2, listen_error_message, sizeof(listen_error_message));
      mov r7, #4
      mov r0, #2
      ldr r1, =.accept_error_message
      mov r2, #accept_error_message_length
      swi #0
      @ exit(1);
      mov r7, #1
      mov r0, #1
      swi #0
   .accept_error_message:
      .ascii "failed to accept the connection:\naccept returned -1"
   accept_error_message_length = . - .accept_error_message
