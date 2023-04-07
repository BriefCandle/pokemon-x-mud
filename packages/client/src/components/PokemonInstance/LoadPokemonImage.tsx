import { useState, useEffect } from 'react';

export enum PokemonImageType {
  front,
  back,
  icon
}

// Helper function to convert enum variable to string name
export const getEnumName = (enumType: any, enumValue: any): string => {
  const keys = Object.keys(enumType).filter(key => enumType[key] === enumValue);
  return keys.length > 0 ? keys[0] : '';
};

export const LoadPokemonImage = (props: {classIndex: number, imageType: PokemonImageType}) => {
  const {classIndex, imageType } = props;
  const imageType_name = getEnumName(PokemonImageType, imageType);

  const [imageSrc, setImageSrc] = useState(null);

  // useEffect(() => {
    const loadImage = async () => {
      try {
        const image = await import(`../../assets/pokemon/${classIndex}_${imageType_name}.png`);
        setImageSrc(image.default);
      } catch (error) {
        console.error('Failed to load image:', error);
      }
    }
    loadImage();
  // }, [])

  return (
    <div>
      {imageSrc ? (
        <img src={imageSrc} alt="Example" style={{width: "100% !important", maxWidth: "none !important"}}/>
      ) : (
        <p>Loading image...</p>
      )}
    </div>
  );
}