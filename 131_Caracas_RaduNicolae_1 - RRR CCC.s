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

    cmp $3, %eax
    je cerinta3
    jmp et_exit_3


cerinta3:
# citire n
    pushl $n
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx
#calc dimensiune matrice (4*n*n)
    movl $4,%eax
    mull n
    mull n 
    movl %eax,spatiu_matr
#alocare cu mmap2   
    #mres
    movl    $192, %eax #syscall
    movl    $0, %ebx # Setam adresa null => kernel decide adresa
    movl    spatiu_matr,%ecx    #   dimensiune matrice
    movl    $0x3, %edx          #   codul pentru PROT_READ(0x1) | PROT_WRITE(0x2) obtinut din iorarea lor
    movl    $0x22, %esi         #   MAP_PRIVATE (0x2) 
                                #   mapping are not visible to other processes mapping the
                                #   same file, and are not carried through to the underlying
                                #   file. 
                                #   MAP_ANON (0X20) 
                                #   Updates to the mapping are visible to
                                #   other processes mapping the same region
                                #   0x22 COD obtiunut prin iorare, deoarece nu folosesc fisier si am un singur proces si o zona de memorie pe care o vreau accesibila
    movl    $-1, %edi           #   nu exista FD daca avem MAP_ANON
    movl    $0, %ebp
    int     $0x80
    movl %eax , matricer #salvam adresa matrice resultat
    #m1
    movl    $192, %eax
    movl    $0, %ebx
    movl    spatiu_matr, %ecx    
    movl    $0x3, %edx          
    movl    $0x22, %esi         
    movl    $-1, %edi           
    movl    $0, %ebp
    int     $0x80
    movl %eax,matrice1
    #m2
    movl    $192, %eax
    movl    $0, %ebx
    movl    spatiu_matr, %ecx    
    movl    $0x3, %edx          
    movl    $0x22, %esi         
    movl    $-1, %edi           
    movl    $0, %ebp
    int     $0x80
    movl %eax,matrice2




    # citire nr de muchii pentru fiecare nod
    lea no_edges, %edi
    movl $0, %ecx
for3:
    pusha
    pushl $aux
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx
    popa
    movl aux, %eax
    movl %eax, (%edi, %ecx, 4)
end_for3:
    inc %ecx
    cmp %ecx, n
    jg for3

    # citire muchii pentru fiecare nod si completare matrice
    lea no_edges, %edi
    movl $0, %ecx
for_03:
    movl (%edi, %ecx, 4), %eax
    movl %eax, index
    movl %ecx, poz
    # testam daca index este 0 sa treaca peste
    cmp $0, index
    je end_for_03
    pusha # salv eax, ecx, edi/reinitializez pentru for_1
    lea edges, %edi
    movl $0, %ecx
for_13:
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
    movl matrice1, %edi
    movl poz, %eax
    mull n
    addl aux, %eax
    addl $1, (%edi, %eax, 4)
    popa
end_for13:
    inc %ecx
    cmp %ecx, index
    jg for_13
    popa # restaurez eax, ecx, edi pentru for
end_for_03:
    inc %ecx
    cmp %ecx, n
    jg for_03
citirekji3:
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

aflaredrum3:
#AD^k afisare a[i][j]
    
    cmp $1,k 
    je afisare_nr_drum3
    movl k,%ecx
    decl %ecx
    #apel initial m1,m1
    #m2=m1
    jmp inmultire_init3
    iesire_inmultire3:
    decl %ecx
    cmp $0,%ecx 
    je afisare_nr_drum3
for_drum3:
    #m2=mres
    jmp inmultire3 
    drum3:
    loop for_drum3
afisare_nr_drum3:
    movl i,%eax
    mull n
    addl j,%eax

    movl matricer,%edi
    
    pushl (%edi,%eax,4)
    pushl $formatScanf
    call printf
    popl %ebx
    popl %ebx
    pushl $0
    call fflush
    popl %ebx
 
et_exit_3:
    movl $1, %eax
    movl $0, %ebx
    int $0x80

inmultire3:
    pusha
    pushl n 
    pushl matricer
    pushl matricer
    pushl matrice1
    call matrix_mult
    popl %edx
    popl %edx
    popl %edx
    popl %edx
    popa
    jmp drum3
inmultire_init3:
    pusha
    pushl n 
    pushl matricer
    pushl matrice1
    pushl matrice1
    call matrix_mult
    popl %edx
    popl %edx
    popl %edx
    popl %edx
    popa
    jmp iesire_inmultire3