#!/bin/bash
jv_pg_gmail () {
    local last_check_file="/tmp/jarvis_gmail_last_check"
    local last_from
    local in_entry=false
    local stop=false
    local first_entry=true
    local nb_unread=0
    local last_check="$(cat "$last_check_file" 2>/dev/null)"
    
    $gmail_say_checking && say "Controllo la posta..."
    
    while jv_read_dom; do
        case "$ENTITY" in
            #fullcount) nb_unread="$CONTENT";;
            H1)    jv_error "ERROR: $CONTENT"
                   return 1;;
            title) $first_entry && last_title="$CONTENT";;
            issued) issued="$CONTENT"
                    $first_entry && echo "$issued" > "$last_check_file"
                    if [[ "$gmail_only_new" == false ]] || [[ "$issued" > "$last_check" ]]; then
                        ((nb_unread++))
                    else
                        stop=true
                    fi
                    ;;
            name) $first_entry && last_from="$CONTENT";;
            /entry) $first_entry && first_entry=false
                    $stop && break
                    ;;
        esac
    done < <(curl -u $gmail_username:$gmail_password --silent "https://mail.google.com/mail/feed/atom")
    
    if [ "$nb_unread" -eq 1 ]; then
        say "È presente una mail da leggere"
        $gmail_say_from && say " di $last_from$($gmail_say_title && echo ": $last_title")"
    elif [ "$nb_unread" -ne 0 ]; then
        say "Ci sono $nb_unread mail da leggere"
        $gmail_say_from && say "L'ultima mail è di $last_from$($gmail_say_title && echo ": $last_title")"
    else
        $gmail_say_no_new && say "Non ci sono mail da leggere"
    fi
    return 0
}
