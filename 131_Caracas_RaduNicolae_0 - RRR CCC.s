.data
cerinta: .space 4
matrix: .space 10000
n: .space 4
aux: .space 4
no_edges: .space 400
index: .space 4
poz: .space 4
edges: .space 400
formatScanf: .asciz "%ld"
formatPrintf: .asciz "%ld "
NewLine: .asciz "\n"
rand: .space 4
coloana: .space 4
k: .space 4
i: .space 4
j: .space 4
m1:.space 10000
m2:.space 10000
mres:.space 10000
spatiu_matr: .space 4
matricer: .space 4
matrice1: .space 4
matrice2: .space 4

.text

matrix_mult:
    #newStack
    push %ebp
    movl %esp,%ebp
    #callee save
    push %esi
    push %edi
    push %ebx

    
    #preluare parametrii
    #8(%ebp) #m1
    #12(%ebp)#m2
    #16(%ebp)#mres
    #20(%ebp)#n
    
    #alocare spatiu pentru variabile
   
    subl $4,%esp #-16(%ebp) :i
    subl $4,%esp #-20(%ebp) :j
    subl $4,%esp #-24(%ebp) :k
    subl $4,%esp #-28(%ebp) :a
    subl $4,%esp #-32(%ebp) :b
    movl $0, -28(%ebp) #a=0
    movl $0, -32(%ebp) #b=0
    
    #inmultire
    movl $0, -16(%ebp) 
    for_i:
    movl -16(%ebp),%ecx
    cmp %ecx,20(%ebp)
    je mexit

    movl $0,-20(%ebp)
    for_j:
    movl -20(%ebp),%ecx 
    cmp %ecx,20(%ebp)
    je end_for_i
    
    movl $0,-24(%ebp)
    for_k:
    movl -24(%ebp),%ecx
    cmp %ecx,20(%ebp)
    je end_for_j
    #calc matrice
    a:
    add $0,%eax
    movl $0,%edx
    movl -16(%ebp),%eax
    movl 20(%ebp),%ebx
    mul %ebx
    addl -24(%ebp), %eax #i*n+k
    movl %eax,%ebx
    movl 8(%ebp),%esi
    movl (%esi, %ebx, 4), %ecx
    movl %ecx, -28(%ebp)  #a=a[i][k]
    b:
    movl 12(%ebp),%esi
    add $0,%eax
    movl $0,%edx
    movl -24(%ebp),%eax
    movl 20(%ebp),%ebx
    mul %ebx
    addl -20(%ebp), %eax #k*n+j
    movl %eax, %ebx
    movl (%esi, %ebx, 4), %ecx #=b[k][j]

    movl -28(%ebp), %eax
    movl $0,%edx
    mull %ecx 
    addl %eax, -32(%ebp) #b=a[i][k]*b[k][j]    
    incl -24(%ebp)
    jmp for_k
    end_for_j:
    movl 16(%ebp),%edi
    movl -32(%ebp),%ecx
    movl $0,%eax
    movl $0,%edx
    movl -16(%ebp),%eax
    movl 20(%ebp),%ebx
    mull %ebx
    addl -20(%ebp) ,%eax # i*n+j
    movl %ecx, (%edi,%eax,4) #c[i][j]+=b
    incl -20(%ebp)
    movl $0, -24(%ebp)
    movl $0, -32(%ebp)
    jmp for_j
    
    end_for_i:
    incl -16(%ebp)
    movl $0, -20(%ebp)
    movl $0, -24(%ebp)
    movl $0, -32(%ebp)
    jmp for_i
mexit:
    #dezalocam variabile
    addl $20, %esp 
    #remake Stack
    popl %ebx
    popl %edi
    popl %esi

    popl %ebp
    ret


.global main

main:
    # citire nr cerinta
    pushl $cerinta
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    # cerinta1
    movl cerinta, %eax
    cmp $1, %eax
    je cerinta1
    # cerinta2
    cmp $2, %eax
    je cerinta_2
   
    jmp exit
cerinta1:
    # citire n
    pushl $n
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    # initializare matrice cu 0
    lea matrix, %edi
    movl $0, %ecx
init_loop:
    movl $0, %eax
    movl %eax, (%edi, %ecx, 4)
end_init_loop:
    inc %ecx
    cmp %ecx, n
    jg init_loop

    # citire nr de muchii pentru fiecare nod
    lea no_edges, %edi
    movl $0, %ecx
for:
    pusha
    pushl $aux
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    popa
    movl aux, %eax
    movl %eax, (%edi, %ecx, 4)
end_for:
    inc %ecx
    cmp %ecx, n
    jg for

    # citire muchii pentru fiecare nod si completare matrice
    lea no_edges, %edi
    movl $0, %ecx
for_0:
    movl (%edi, %ecx, 4), %eax
    movl %eax, index
    movl %ecx, poz
    # testam daca index este 0 sa treaca peste
    cmp $0, index
    je end_for_0
    pusha # salv eax, ecx, edi/reinitializez pentru for_1
    lea edges, %edi
    movl $0, %ecx
for_1:
    pusha
    push $aux
    push $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    popa
    movl aux, %eax
    movl %eax, (%edi, %ecx, 4)
    # completarea matricei
    pusha
    lea matrix, %edi
    movl poz, %eax
    mull n
    addl aux, %eax
    addl $1, (%edi, %eax, 4)
    popa
end_for1:
    inc %ecx
    cmp %ecx, index
    jg for_1
    popa # restaurez eax, ecx, edi pentru for
end_for_0:
    inc %ecx
    cmp %ecx, n
    jg for_0
et_afis_matr:
    movl $0, rand
for_lines:
    movl rand, %ecx
    cmp %ecx, n
    je et_exit
    movl $0, coloana
for_columns:
    movl coloana, %ecx
    cmp %ecx, n
    je cont
    movl rand, %eax
    movl $0, %edx
    mull n
    addl coloana, %eax
    lea matrix, %edi
    movl (%edi, %eax, 4), %ebx
    pushl %ebx
    pushl $formatPrintf
    call printf
    popl %ebx
    popl %ebx
    pushl $0
    call fflush
    popl %ebx
    incl coloana
    jmp for_columns
cont:
    movl $4, %eax
    movl $1, %ebx
    movl $NewLine, %ecx
    movl $1, %edx
    int $0x80
    incl rand
    jmp for_lines
et_exit:
    movl $1, %eax
    movl $0, %ebx
    int $0x80


cerinta_2:
   # citire n
    pushl $n
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    # initializare matrice cu 0
    lea m1, %edi
    movl $0, %ecx
init_loop2:
    movl $0, %eax
    movl %eax, (%edi, %ecx, 4)
end_init_loop2:
    inc %ecx
    cmp %ecx, n
    jg init_loop2

    # citire nr de muchii pentru fiecare nod
    lea no_edges, %edi
    movl $0, %ecx
for2:
    pusha
    pushl $aux
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    popa
    movl aux, %eax
    movl %eax, (%edi, %ecx, 4)
end_for2:
    inc %ecx
    cmp %ecx, n
    jg for2

    # citire muchii pentru fiecare nod si completare matrice
    lea no_edges, %edi
    movl $0, %ecx
for_02:
    movl (%edi, %ecx, 4), %eax
    movl %eax, index
    movl %ecx, poz
    # testam daca index este 0 sa treaca peste
    cmp $0, index
    je end_for_02
    pusha # salv eax, ecx, edi/reinitializez pentru for_1
    lea edges, %edi
    movl $0, %ecx
for_12:
    pusha
    push $aux
    push $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    popa
    movl aux, %eax
    movl %eax, (%edi, %ecx, 4)
    # completarea matricei
    pusha
    lea m1, %edi
    movl poz, %eax
    mull n
    addl aux, %eax
    addl $1, (%edi, %eax, 4)
    popa
end_for12:
    inc %ecx
    cmp %ecx, index
    jg for_12
    popa # restaurez eax, ecx, edi pentru for
end_for_02:
    inc %ecx
    cmp %ecx, n
    jg for_02
citirekji:
    pushl $k
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    pushl $i
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    pushl $j
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx

aflaredrum:
#AD^k afisare a[i][j]
    
    cmp $1,k 
    je afisare_nr_drum
    movl k,%ecx
    decl %ecx
    #apel initial m1,m1
    #m2=m1
    jmp inmultire_init
    iesire_inmultire:
    decl %ecx
    cmp $0,%ecx 
    je afisare_nr_drum
for_drum:
    #m2=mres
    jmp inmultire
    drum:
    loop for_drum
afisare_nr_drum:
    movl i,%eax
    mull n
    addl j,%eax

    lea mres,%edi
    
    pushl (%edi,%eax,4)
    pushl $formatScanf
    call printf
    popl %ebx
    popl %ebx
    pushl $0
    call fflush
    popl %ebx
 
et_exit_2:
    movl $1, %eax
    movl $0, %ebx
    int $0x80

inmultire:
    pusha
    pushl n 
    pushl $mres
    pushl $mres
    pushl $m1
    call matrix_mult
    popl %edx
    popl %edx
    popl %edx
    popl %edx
    popa
    jmp drum
inmultire_init:
    pusha
    pushl n 
    pushl $mres
    pushl $m1
    pushl $m1
    call matrix_mult
    popl %edx
    popl %edx
    popl %edx
    popl %edx
    popa
    jmp iesire_inmultire

