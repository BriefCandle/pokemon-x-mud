import  { useState, useEffect, useRef } from "react";

export const PrintText = (props: { text: string, delay: number }) => {
  const {text, delay} = props;
  const [printedText, setPrintedText] = useState("");

  useEffect(() => {
    let i = 0;
    const printNextChar = () => {
      if (i < text.length) {
        setPrintedText((prev) => prev + text.charAt(i));
        i++;
        setTimeout(printNextChar, delay);
      }
    };
    printNextChar();
  }, [text, delay]);


  return <h1 style={{color: "black"}}>{printedText}</h1>;
};